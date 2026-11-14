#!/usr/bin/env python3
"""本项目的保守启动器：检查连接、复用已验证服务，绝不导入或恢复数据库。"""

import argparse
import datetime
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import socket
import stat
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request
import webbrowser


ROOT = Path(__file__).resolve().parent.parent
BACKEND = ROOT / "springboot"
FRONTEND = ROOT / "vue3"
JAR = BACKEND / "target/springboot-0.0.1-SNAPSHOT.jar"
VITE = FRONTEND / "node_modules/vite/bin/vite.js"
LOCAL_CONFIG = BACKEND / "application-local.yml"
RUNTIME = ROOT / ".local-runtime"
DEPLOYMENTS = RUNTIME / "deployments"
MYSQL = Path("/usr/local/mysql/bin/mysql")
MYSQL_DATA = Path("/usr/local/mysql/data")
HOME_URL = "http://127.0.0.1:8800/home"
API_PATH = "/api/heritage-item/page?current=1&size=1"


class CheckError(Exception):
    pass


def yaml_scalar(raw):
    """仅解析 datasource 的单行标量；不执行 YAML 标签或表达式。"""
    quote = None
    escaped = False
    end = len(raw)
    for i, char in enumerate(raw):
        if escaped:
            escaped = False
        elif quote == '"' and char == "\\":
            escaped = True
        elif char == quote:
            quote = None
        elif quote is None and char in ("'", '"'):
            quote = char
        elif quote is None and char == "#" and (i == 0 or raw[i - 1].isspace()):
            end = i
            break
    value = raw[:end].strip()
    if value.startswith('"'):
        try:
            return json.loads(value)
        except (ValueError, TypeError):
            raise CheckError("数据库本地配置含无法解析的引号，请检查 application-local.yml。")
    if value.startswith("'") and value.endswith("'"):
        return value[1:-1].replace("''", "'")
    if not value or value.startswith(("|", ">", "!", "&", "*", "{", "[")):
        raise CheckError("数据库本地配置须使用普通单行文本值。")
    return value


def read_datasource(path):
    values = {}
    in_spring = False
    in_datasource = False
    if path.is_file():
        # 到 datasource 的下一个同级区段就停止；不解析 AI 密钥等其他配置。
        with path.open(encoding="utf-8-sig") as handle:
            for raw in handle:
                line = raw.rstrip("\r\n")
                if not line.strip() or line.lstrip().startswith("#"):
                    continue
                if "\t" in line[:len(line) - len(line.lstrip())]:
                    raise CheckError("application-local.yml 的缩进需要使用空格。")
                indent = len(line) - len(line.lstrip(" "))
                stripped = line.strip()
                if in_datasource and indent <= 2:
                    break
                if indent == 0:
                    in_spring = stripped == "spring:"
                elif in_spring and indent == 2:
                    in_datasource = stripped == "datasource:"
                elif in_datasource and indent == 4:
                    key, separator, value = stripped.partition(":")
                    if separator and key in ("url", "username", "password"):
                        values[key] = yaml_scalar(value)
    return values


def datasource_config():
    names = ("url", "username", "password")
    if not LOCAL_CONFIG.is_file() and not all("SPRING_DATASOURCE_" + key.upper() in os.environ for key in names):
        raise CheckError("缺少数据库本地配置，请保留 springboot/application-local.yml；启动器不会重置或重建数据库。")
    values = read_datasource(BACKEND / "src/main/resources/application.yml")
    values.update(read_datasource(LOCAL_CONFIG))
    for key, value in values.items():
        expression = re.fullmatch(r"\$\{([A-Z][A-Z0-9_]*):(.*)\}", value)
        if expression:
            values[key] = os.environ.get(expression.group(1), expression.group(2))
    for key in names:
        env_name = "SPRING_DATASOURCE_" + key.upper()
        if env_name in os.environ:
            values[key] = os.environ[env_name]
    if not all(key in values for key in names):
        raise CheckError("缺少数据库本地配置，请保留 springboot/application-local.yml；启动器不会重置或重建数据库。")
    url = values["url"]
    if not isinstance(url, str) or not url.startswith("jdbc:mysql://"):
        raise CheckError("数据库地址必须是本地 MySQL JDBC 地址。")
    try:
        parsed = urllib.parse.urlsplit(url[5:])
        correct = (parsed.hostname == "127.0.0.1" and (parsed.port or 3306) == 3306
                   and urllib.parse.unquote(parsed.path) == "/heritage_db"
                   and parsed.username is None and parsed.password is None)
    except ValueError:
        correct = False
    if not correct:
        raise CheckError("数据库配置不一致：只允许 127.0.0.1:3306/heritage_db。已停止，避免连接到其他库。")
    if any("${" in str(value) for value in values.values()):
        raise CheckError("本地 datasource 存在未展开的变量，请设置对应 SPRING_DATASOURCE_* 环境变量。")
    return values


def mysql_option(value):
    return '"' + str(value).replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\r", "\\r") + '"'


def check_database(values):
    if not MYSQL.is_file():
        raise CheckError("未找到官方 MySQL 8 客户端 /usr/local/mysql/bin/mysql；不会改用 Homebrew 实例。")
    temp_path = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", prefix="heritage-db-check-", delete=False) as handle:
            temp_path = Path(handle.name)
            os.chmod(temp_path, 0o600)
            handle.write("[client]\nuser=" + mysql_option(values["username"]) + "\npassword=" + mysql_option(values["password"]) + "\n")
        result = subprocess.run(
            [str(MYSQL), "--defaults-file=" + str(temp_path), "--protocol=TCP",
             "--host=127.0.0.1", "--port=3306", "--database=heritage_db",
             "--connect-timeout=5", "--batch", "--skip-column-names",
             "--execute=SELECT @@version, @@port, @@datadir, DATABASE();"],
            capture_output=True, text=True, timeout=12,
        )
        if result.returncode:
            error = result.stderr
            if "1045" in error:
                message = "MySQL 身份验证失败，请核对本地数据库账号密码；不会自动改密码。"
            elif "1049" in error:
                message = "当前 MySQL 中没有 heritage_db。请先核对实例和备份，勿重新导入旧 SQL。"
            elif "2002" in error or "2003" in error:
                message = ("无法连接本地 MySQL。若官方 MySQL 尚未运行，请在终端执行：\n"
                           "  sudo /usr/local/mysql/support-files/mysql.server start\n"
                           "输入的是电脑登录密码（输入时不显示字符），随后重新双击项目启动。\n"
                           "请勿执行 brew services start mysql，以免启动另一套实例。")
            else:
                message = "MySQL 检查失败，请检查官方 MySQL 状态和本地配置；为保护凭据不显示原始错误。"
            raise CheckError(message)
        fields = result.stdout.strip().split("\t")
        if len(fields) != 4:
            raise CheckError("MySQL 返回信息异常，无法确认数据库实例。")
        version, port, datadir, database = fields
        if not version.startswith("8.") or port != "3306" or database != "heritage_db":
            raise CheckError("数据库实例不一致：需要官方 MySQL 8、3306 端口及 heritage_db，已停止。")
        if os.path.realpath(datadir) != os.path.realpath(MYSQL_DATA):
            raise CheckError("数据库数据目录不是 /usr/local/mysql/data，已停止，避免连接错误实例。")
        print("[正常] 官方 MySQL " + version + "，heritage_db 连接成功，数据目录核对通过。")
    except subprocess.TimeoutExpired:
        raise CheckError("MySQL 检查超时，请检查数据库服务；本次没有修改任何数据库数据。")
    finally:
        if temp_path is not None:
            temp_path.unlink(missing_ok=True)


def run_probe(args):
    try:
        return subprocess.run(args, capture_output=True, text=True, timeout=5)
    except (OSError, subprocess.TimeoutExpired):
        raise CheckError("无法执行进程身份检查，请在本机终端运行此工具。")


def port_connects(port):
    try:
        with socket.create_connection(("127.0.0.1", port), timeout=1):
            return True
    except OSError:
        return False


def deployment_matches(path):
    """只接受本项目部署目录内、名称与内容 SHA256 一致的普通 JAR。"""
    path = Path(os.path.abspath(path))
    match = re.fullmatch(r"springboot-([0-9a-f]{64})\.jar", path.name)
    if path.parent != DEPLOYMENTS or not match:
        return False
    if RUNTIME.is_symlink() or DEPLOYMENTS.is_symlink() or path.is_symlink():
        raise CheckError("后端部署目录和 JAR 不允许使用符号链接，请人工核对。")
    try:
        descriptor = os.open(path, os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0))
        with os.fdopen(descriptor, "rb") as handle:
            before = os.fstat(handle.fileno())
            if not stat.S_ISREG(before.st_mode) or before.st_uid != os.getuid():
                return False
            digest = hashlib.sha256()
            for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                digest.update(chunk)
            after = os.fstat(handle.fileno())
        unchanged = (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns) == (
            after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns)
        return unchanged and digest.hexdigest() == match.group(1)
    except OSError:
        return False


def backend_jar_matches(path):
    path = Path(os.path.abspath(path))
    if path == JAR:
        return True  # 兼容旧启动方式；新启动始终使用下方的独立部署副本。
    return deployment_matches(path)


def existing_service(port, directory, kind):
    lsof = shutil.which("lsof") or "/usr/sbin/lsof"
    result = run_probe([lsof, "-nP", "-iTCP:" + str(port), "-sTCP:LISTEN", "-Fp"])
    pids = set(re.findall(r"^p(\d+)$", result.stdout, flags=re.MULTILINE))
    if not pids:
        if port_connects(port) or result.returncode not in (0, 1) or result.stderr.strip():
            raise CheckError(str(port) + " 端口状态无法核实；请在本机终端检查端口，不会停止或覆盖现有程序。")
        return None
    if len(pids) != 1:
        raise CheckError(str(port) + " 端口存在多个监听进程，无法安全复用。")
    pid = int(next(iter(pids)))
    cwd_result = run_probe([lsof, "-a", "-p", str(pid), "-d", "cwd", "-Fn"])
    cwd_paths = [line[1:] for line in cwd_result.stdout.splitlines() if line.startswith("n")]
    command_result = run_probe(["/bin/ps", "-p", str(pid), "-o", "command="])
    if cwd_result.returncode or command_result.returncode or len(cwd_paths) != 1:
        raise CheckError(str(port) + " 端口已有进程，但无法读取其身份；不会停止或替换它。")
    try:
        tokens = shlex.split(command_result.stdout.strip())
    except ValueError:
        tokens = []
    correct_cwd = Path(cwd_paths[0]).resolve() == directory.resolve()
    executable = Path(tokens[0]).name if tokens else ""
    if kind == "backend":
        correct_command = executable == "java" and any(
            backend_jar_matches(directory / token)
            for token in tokens[1:] if token.endswith(".jar")
        )
    else:
        correct_command = executable == "node" and any(
            (directory / token).resolve() == VITE.resolve()
            for token in tokens[1:] if "vite" in token and not token.startswith("-")
        )
        # npm 启动的 Vite 会把进程标题改为 node (.../vite)，保留 cwd 核验。
        if executable == "node" and re.search(r"\(.*[/]vite\)", command_result.stdout):
            correct_command = True
    if not correct_cwd or not correct_command:
        raise CheckError(str(port) + " 端口被其他程序或其他目录的项目占用；请人工核对，启动器不会结束它。")
    return pid


def api_is_healthy(port):
    try:
        opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
        with opener.open("http://127.0.0.1:" + str(port) + API_PATH, timeout=3) as response:
            data = json.loads(response.read(1_000_000))
            return response.status == 200 and isinstance(data, dict) and str(data.get("code")) == "200"
    except (OSError, ValueError, urllib.error.URLError):
        return False


def frontend_is_healthy():
    try:
        opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
        request = urllib.request.Request(HOME_URL, headers={"Accept": "text/html"})
        with opener.open(request, timeout=3) as response:
            html = response.read(300_000)
            return response.status == 200 and b"/src/main.js" in html and api_is_healthy(8800)
    except (OSError, urllib.error.URLError):
        return False


def prepare_runtime():
    if RUNTIME.is_symlink():
        raise CheckError(".local-runtime 不应是符号链接，请人工核对。")
    RUNTIME.mkdir(mode=0o700, exist_ok=True)
    if RUNTIME.stat().st_uid != os.getuid():
        raise CheckError("运行目录不属于当前用户，请人工核对权限。")
    RUNTIME.chmod(0o700)


def prepare_backend_jar():
    """复制构建产物后发布唯一内容名；绝不覆盖已有运行副本。"""
    if RUNTIME.is_symlink() or DEPLOYMENTS.is_symlink() or JAR.is_symlink():
        raise CheckError("后端 JAR 与部署目录不允许使用符号链接，请人工核对。")
    DEPLOYMENTS.mkdir(mode=0o700, exist_ok=True)
    if DEPLOYMENTS.stat().st_uid != os.getuid():
        raise CheckError("后端部署目录不属于当前用户，请人工核对权限。")
    DEPLOYMENTS.chmod(0o700)
    temporary = None
    try:
        descriptor = os.open(JAR, os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0))
        with os.fdopen(descriptor, "rb") as source:
            before = os.fstat(source.fileno())
            if not stat.S_ISREG(before.st_mode):
                raise CheckError("后端构建产物不是普通文件。")
            digest = hashlib.sha256()
            with tempfile.NamedTemporaryFile(mode="wb", dir=DEPLOYMENTS, prefix=".jar-stage-", delete=False) as target:
                temporary = Path(target.name)
                os.fchmod(target.fileno(), 0o600)
                for chunk in iter(lambda: source.read(1024 * 1024), b""):
                    target.write(chunk)
                    digest.update(chunk)
                target.flush()
                os.fsync(target.fileno())
            after = os.fstat(source.fileno())
        if (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns) != (
                after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns):
            raise CheckError("复制期间后端构建产物发生变化，请等构建完成后重新启动。")
        destination = DEPLOYMENTS / ("springboot-" + digest.hexdigest() + ".jar")
        try:
            # 发布时不覆盖同名文件，避免影响任何正在运行的 JVM。
            os.link(temporary, destination, follow_symlinks=False)
        except FileExistsError:
            if not deployment_matches(destination):
                raise CheckError("已有后端部署副本校验失败，已停止；不会覆盖正在运行的文件。")
        if destination.is_symlink():
            raise CheckError("后端部署 JAR 不允许使用符号链接。")
        destination.chmod(0o600)
        return destination
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def launch(kind, values):
    if kind == "backend":
        executable = shutil.which("java")
        if not executable or not JAR.is_file():
            raise CheckError("缺少 Java 或已构建的后端 jar，请先完成构建；启动器不会自动安装或构建。")
        deployed_jar = prepare_backend_jar()
        command = [executable, "-jar", str(deployed_jar), "--server.port=8889"]
        directory = BACKEND
    else:
        executable = shutil.which("node")
        if not executable:
            executable = next((str(path) for path in (Path("/usr/local/bin/node"), Path("/opt/homebrew/bin/node"))
                               if path.is_file() and os.access(path, os.X_OK)), None)
        if not executable or not VITE.is_file():
            raise CheckError("缺少 Node.js 或前端依赖，请先完成安装；启动器不会自动下载软件。")
        command = [executable, str(VITE), "--mode", "development", "--host", "127.0.0.1", "--port", "8800", "--strictPort"]
        directory = FRONTEND
    environment = os.environ.copy()
    for key in ("url", "username", "password"):
        environment["SPRING_DATASOURCE_" + key.upper()] = values[key]
    if kind == "backend":
        # This local academic checkout exposes only a clearly labeled no-charge demo flow.
        # Packaged/production runs keep the demo endpoint disabled by default.
        environment["HERITAGE_PAYMENT_DEMO_ENABLED"] = "true"
    environment["BROWSER"] = "none"
    log_path = RUNTIME / (kind + ".log")
    flags = os.O_WRONLY | os.O_CREAT | os.O_APPEND | getattr(os, "O_NOFOLLOW", 0)
    descriptor = os.open(log_path, flags, 0o600)
    os.fchmod(descriptor, 0o600)
    with os.fdopen(descriptor, "ab") as log:
        process = subprocess.Popen(command, cwd=directory, env=environment,
                                   stdin=subprocess.DEVNULL, stdout=log,
                                   stderr=subprocess.STDOUT, start_new_session=True)
    return process


def wait_until_ready(check, process, seconds, label):
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
        if process.poll() is not None:
            raise CheckError(label + " 已退出，请检查 .local-runtime 中的对应日志。")
        if check():
            return
        time.sleep(1)
    raise CheckError(label + " 在限定时间内未通过检查，请查看 .local-runtime 日志；不会重复启动或清空数据。")


def status(values):
    failures = []
    try:
        check_database(values)
    except CheckError as error:
        failures.append(str(error))
    for label, port, directory, kind, health in (
        ("后端", 8889, BACKEND, "backend", lambda: api_is_healthy(8889)),
        ("前端与数据库代理", 8800, FRONTEND, "frontend", frontend_is_healthy),
    ):
        try:
            pid = existing_service(port, directory, kind)
            if not pid:
                raise CheckError(label + " 尚未启动。")
            if not health():
                raise CheckError(label + " 进程存在，但业务接口尚未通过检查。")
            print("[正常] " + label + "，端口 " + str(port) + "，PID " + str(pid) + "。")
        except CheckError as error:
            failures.append(str(error))
    for failure in failures:
        print("[待处理] " + failure)
    return 1 if failures else 0


def start(values, open_browser):
    check_database(values)
    prepare_runtime()
    lock_path = RUNTIME / "startup.lock"
    descriptor = os.open(lock_path, os.O_CREAT | os.O_RDWR | getattr(os, "O_NOFOLLOW", 0), 0o600)
    os.fchmod(descriptor, 0o600)
    with os.fdopen(descriptor, "w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise CheckError("另一个项目启动器正在检查，请稍候再试。")
        # 先核对两个端口，避免发现前端冲突后才启动后端。
        backend_pid = existing_service(8889, BACKEND, "backend")
        frontend_pid = existing_service(8800, FRONTEND, "frontend")
        if backend_pid:
            if not api_is_healthy(8889):
                raise CheckError("现有后端未通过数据库业务接口检查，请先查看日志；不会强制重启。")
            print("[复用] 已核对本项目后端，端口 8889。")
        else:
            print("[启动] 正在启动后端，最多等待 60 秒……")
            process = launch("backend", values)
            backend_pid = process.pid
            wait_until_ready(lambda: api_is_healthy(8889), process, 60, "后端")
        if frontend_pid:
            if not frontend_is_healthy():
                raise CheckError("现有前端未通过页面与 API 代理检查，请查看日志；不会强制重启。")
            print("[复用] 已核对本项目前端，端口 8800。")
        else:
            print("[启动] 正在启动前端，最多等待 30 秒……")
            process = launch("frontend", values)
            frontend_pid = process.pid
            wait_until_ready(frontend_is_healthy, process, 30, "前端")
        state_path = RUNTIME / "state.json"
        state = {"checked_at": datetime.datetime.now().astimezone().isoformat(),
                 "project": str(ROOT), "backend_pid": backend_pid,
                 "frontend_pid": frontend_pid, "url": HOME_URL}
        state_fd = os.open(state_path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC | getattr(os, "O_NOFOLLOW", 0), 0o600)
        os.fchmod(state_fd, 0o600)
        with os.fdopen(state_fd, "w", encoding="utf-8") as handle:
            json.dump(state, handle, ensure_ascii=False, indent=2)
        print("[完成] 页面和数据库读取链路检查通过：" + HOME_URL)
        print("关闭此终端不会停止网页服务；电脑关机或重启后，请再次双击项目启动。")
        if open_browser:
            webbrowser.open(HOME_URL)
    return 0


def main():
    parser = argparse.ArgumentParser(description="非遗传承：安全启动及只读状态检查")
    parser.add_argument("--status", action="store_true", help="只读检查，不启动、不停止、不写运行文件")
    parser.add_argument("--no-browser", action="store_true", help="启动完成后不打开浏览器")
    args = parser.parse_args()
    print("非遗传承 · " + ("只读状态检查" if args.status else "本地启动"))
    try:
        values = datasource_config()
        return status(values) if args.status else start(values, not args.no_browser)
    except (CheckError, OSError) as error:
        # 不输出命令行或 traceback，避免暴露配置内容。
        message = str(error) if isinstance(error, CheckError) else "无法访问本地文件或启动程序，请检查本机权限及运行目录。"
        print("[已停止] " + message)
        return 1
    except KeyboardInterrupt:
        print("\n检查已取消；没有清空或恢复数据库。")
        return 130


if __name__ == "__main__":
    sys.exit(main())
