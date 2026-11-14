#!/usr/bin/env python3
"""Create a fresh, private backup without modifying the running database."""
import ast
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile
import tempfile
from datetime import datetime

ROOT = Path(__file__).resolve().parents[1]
MYSQL = Path('/usr/local/mysql/bin/mysql')
DUMP = Path('/usr/local/mysql/bin/mysqldump')
LOCAL_CONFIG = ROOT / 'springboot/application-local.yml'


def credentials():
    values = {}
    section = []
    for line in LOCAL_CONFIG.read_text(encoding='utf-8').splitlines():
        if not line.strip() or line.lstrip().startswith('#') or ':' not in line:
            continue
        indent = len(line) - len(line.lstrip())
        key, value = line.strip().split(':', 1)
        while section and section[-1][0] >= indent:
            section.pop()
        path = [part[1] for part in section] + [key]
        value = value.strip()
        if value:
            if value[0] in "\"'":
                value = ast.literal_eval(value)
            if path == ['spring', 'datasource', 'username']:
                values['user'] = str(value)
            elif path == ['spring', 'datasource', 'password']:
                values['password'] = str(value)
        else:
            section.append((indent, key))
    if 'user' not in values or 'password' not in values:
        raise RuntimeError('本地配置中缺少数据库账号或密码，请检查 application-local.yml。')
    return values


def option_value(value):
    if '\n' in value or '\r' in value:
        raise RuntimeError('数据库配置格式不支持换行。')
    return '"' + value.replace('\\', '\\\\').replace('"', '\\"') + '"'


def digest(path):
    result = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            result.update(chunk)
    return result.hexdigest()


def include_source(info):
    parts = Path(info.name).parts[1:]
    excluded = {'node_modules', 'target', 'dist', '.git', '__pycache__',
                '.DS_Store', 'logs', 'acceptance', '.runtime', '.local-runtime', 'archive'}
    directory_parts = parts if info.isdir() else parts[:-1]
    if any(part in excluded for part in parts) or any('备份' in part for part in directory_parts):
        return None
    if parts and (parts[-1] == 'application-local.yml' or
                  parts[-1] == '.env.local' or parts[-1].endswith('.log')):
        return None
    return info


def main():
    if not MYSQL.is_file() or not DUMP.is_file():
        raise RuntimeError('未找到官方 MySQL 8 客户端，已停止，未使用其他数据库实例。')
    private = credentials()
    backup_root = ROOT / 'archive/runtime-backups'
    backup_root.mkdir(mode=0o700, exist_ok=True)
    backup = backup_root / datetime.now().strftime('%Y%m%d_%H%M%S')
    backup.mkdir(mode=0o700)
    os.chmod(backup, 0o700)
    print('正在连接官方 MySQL 8，核对数据库身份……', flush=True)
    with tempfile.TemporaryDirectory(prefix='heritage-backup-') as temp:
        client = Path(temp) / 'mysql.cnf'
        client.write_text('[client]\nhost=127.0.0.1\nport=3306\nprotocol=TCP\n' +
                          ''.join(key + '=' + option_value(value) + '\n'
                                  for key, value in private.items()), encoding='utf-8')
        os.chmod(client, 0o600)

        def query(sql):
            result = subprocess.run(
                [str(MYSQL), '--defaults-file=' + str(client), '--connect-timeout=5',
                 '--default-character-set=utf8mb4', '--batch', '--skip-column-names',
                 'heritage_db', '-e', sql], text=True, capture_output=True, timeout=15)
            if result.returncode:
                raise RuntimeError('数据库连接或读取失败；请先运行 scripts/start.command 检查服务。')
            return result.stdout.strip()

        version, datadir, database = query('SELECT @@version, @@datadir, DATABASE()').split('\t')
        if not version.startswith('8.') or datadir.rstrip('/') != '/usr/local/mysql/data' or database != 'heritage_db':
            raise RuntimeError('数据库实例与已确认的官方 MySQL 8 不一致，备份已停止。')
        dump_path = backup / 'heritage_db_live.sql'
        print('正在导出当前数据库的一致性快照……', flush=True)
        with dump_path.open('wb') as output:
            result = subprocess.run(
                [str(DUMP), '--defaults-file=' + str(client),
                 '--default-character-set=utf8mb4', '--single-transaction',
                 '--routines', '--events', '--triggers', '--hex-blob',
                 '--no-tablespaces', '--set-gtid-purged=OFF', 'heritage_db'],
                stdout=output, stderr=subprocess.PIPE, timeout=180)
        if result.returncode or dump_path.stat().st_size < 1024:
            raise RuntimeError('数据库导出失败，请勿将此目录当作完成的备份。')
        with dump_path.open('rb') as source:
            source.seek(max(0, dump_path.stat().st_size - 2048))
            if b'-- Dump completed on' not in source.read():
                raise RuntimeError('数据库导出缺少完成标记，请重新备份。')
        tables = query('SHOW TABLES').splitlines()
        counts = {}
        for table in tables:
            escaped = table.replace('`', '``')
            counts[table] = int(query('SELECT COUNT(*) FROM `' + escaped + '`'))
        summary = {'created_at': datetime.now().astimezone().isoformat(),
                   'database': database, 'mysql_version': version,
                   'datadir': datadir, 'table_counts_after_snapshot': counts}
        (backup / 'data-check.json').write_text(
            json.dumps(summary, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

    print('正在保存源码、上传文件和静态资源……', flush=True)
    archive = backup / 'source-and-assets.tar.gz'
    with tarfile.open(archive, 'w:gz') as output:
        output.add(ROOT, arcname=ROOT.name, filter=include_source)
    with tarfile.open(archive, 'r:gz') as source:
        names = source.getnames()
        for required in ('springboot/pom.xml', 'vue3/package.json'):
            if ROOT.name + '/' + required not in names:
                raise RuntimeError('源码归档校验失败，缺少 ' + required)
        if not any(name.startswith(ROOT.name + '/springboot/files/') for name in names):
            raise RuntimeError('源码归档缺少上传资源。')
    config_dir = backup / 'private-config'
    config_dir.mkdir(mode=0o700)
    shutil.copy2(LOCAL_CONFIG, config_dir / 'application-local.yml')
    os.chmod(config_dir / 'application-local.yml', 0o600)
    restore = '''这是当前运行数据库的完整快照，备份过程不会更改在线数据。

1. heritage_db_live.sql 是实时导出；database/heritage_db.sql 是旧初始化样例，日常启动不要导入。
2. source-and-assets.tar.gz 包括源码、springboot/files 上传资源及 vue3/public 静态资源，排除了依赖、构建产物、日志和旧备份。
3. private-config/application-local.yml 含数据库密码及 AI 密钥，只在本机妥善保管，不要上传或公开。
4. 需要恢复时，先停止业务写入并备份恢复前的数据；优先将此 SQL 导入新建的隔离数据库验收。直接导入当前 heritage_db 会覆盖表和恢复点之后的数据！请勿在日常启动时执行。
5. 解压源码后将私密配置放回 springboot/application-local.yml，并保留权限 600；在项目目录运行 scripts/start.command。
6. 文件校验：在本备份目录执行 shasum -a 256 -c SHA256SUMS。完成标记为 backup-complete.json。
7. data-check.json 的计数采集于快照之后；备份期间的新写入可能使计数略有差异。所有业务表为 InnoDB，SQL 使用 --single-transaction 一致性快照。
8. 本机备份可防误操作，不能防止整块硬盘损坏；需要时可将整个备份目录另存到个人外置硬盘。
'''
    (backup / 'restore-notes.txt').write_text(restore, encoding='utf-8')
    files = sorted(path for path in backup.rglob('*') if path.is_file())
    checksums = ''.join(digest(path) + '  ' + str(path.relative_to(backup)) + '\n' for path in files)
    (backup / 'SHA256SUMS').write_text(checksums, encoding='utf-8')
    (backup / 'backup-complete.json').write_text(json.dumps({
        'completed_at': datetime.now().astimezone().isoformat(),
        'database_dump_bytes': dump_path.stat().st_size,
        'source_archive_bytes': archive.stat().st_size,
        'archive_entries': len(names), 'checksummed_files': len(files)},
        ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    for path in backup.rglob('*'):
        if path.is_file():
            os.chmod(path, 0o600)
    print('备份完成：' + str(backup), flush=True)
    print('已核对数据库实例、SQL 完成标记、资源归档和 SHA-256。', flush=True)


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError, tarfile.TarError) as error:
        print('备份未完成：' + str(error), file=sys.stderr)
        sys.exit(1)
