# 本地运行说明

项目目录已统一为英文命名，根目录为 `project`。

## 目录结构

- `springboot/`：Java 后端源码、上传资源和构建产物。
- `vue3/`：Vue 前端源码、静态资源和前端依赖。
- `scripts/`：英文命名的启动、状态检查和备份入口。
- `database/`：旧初始化 SQL 样例；日常启动不会导入。
- `docs/`：运行核验、媒体来源和页面验收资料。
- `archive/`：历史源码快照与实时运行备份。
- `.local-runtime/`：本机服务日志、状态和后端部署副本。

下次打开时，双击 `scripts/start.command`。检查通过后会打开 [用户首页](http://127.0.0.1:8800/home)。如果服务已经运行，会核对项目目录、进程身份和业务接口后直接复用。关闭启动终端不会停止网页服务。

电脑关机或重启后，需要再次双击启动文件。电脑休眠时网页服务也会暂停，唤醒后可双击 `scripts/status.command` 检查。启动器不会修改系统自启动设置。

## 启动前检查

启动器只连接官方 MySQL 8 的 `127.0.0.1:3306/heritage_db`，并核对真实数据目录 `/usr/local/mysql/data`。数据库账号密码来自 `springboot/application-local.yml`（或对应的 `SPRING_DATASOURCE_*` 环境变量），不会显示在终端或记录在状态文件中。

若提示官方 MySQL 未启动，在终端执行：

```sh
sudo /usr/local/mysql/support-files/mysql.server start
```

此处输入电脑登录密码，输入时不显示字符。数据库已运行时不要重复操作。不要用 `brew services start mysql` 启动另一套 MySQL，也不要把数据库数据目录换成 Homebrew 的目录。

前端固定使用 `8800` 端口，后端固定使用 `8889` 端口；其他程序占用时会停止并提示，不会结束其他进程。后端总是在 `springboot` 目录启动，保证上传图片与文件仍从正确的 `files` 目录读取。

## 日常检查与数据保存

双击 `scripts/status.command` 是只读检查，不启动或停止服务，不导入 SQL，不修改数据库，不写运行记录。也可在项目目录执行：

```sh
python3 scripts/project_runtime.py --status
```

检查内容包括数据库实例、前后端进程、后端真实业务查询、前端页面及 API 代理。通过检查代表当时的读取链路正常，不代表已验证每项业务操作或已完成备份。

项目正常启动不会执行导入、恢复或清空数据库。新增和修改的数据保存到 MySQL；上传资源还保存在 `springboot/files`。页面静态图片等位于 `vue3/public`。备份或迁移时应同时保留当前数据库导出、这些资源目录和本地配置；不要把旧的 `database/heritage_db.sql` 当作启动文件重新导入。

需要保存当前版本和数据时，使用 `scripts/backup.command`。备份工具会实时导出数据库，并保留源码及资源；备份位于 `archive/runtime-backups/`，恢复操作应先核对日期和内容。

## 诊断日志

通过启动器新启动的服务日志位于 `.local-runtime/backend.log` 和 `.local-runtime/frontend.log`，状态摘要位于 `.local-runtime/state.json`。目录仅当前用户可访问，状态文件不记录密钥；已有服务的日志保留原来的位置。日志可能包含业务信息，请勿直接公开上传。

启动器只使用本机已存在的 Python 3、Java、Node.js、前端依赖和后端 jar，不自动下载、编译或替换程序。修改后端源码后仍需重新构建并按正常流程重启服务，此工具不会自动热更新后端。

后端新启动时会运行 `.local-runtime/deployments` 中经 SHA256 校验的独立 JAR 副本，因此重新构建源码不会覆盖正在运行的 JAR。

## 商城收款

个人微信收款码位于 `vue3/public/payment/wechat-personal-qr.jpg`。扫码转账不会自动更新订单；管理员需核对微信收款账单后，在订单管理中确认到账。此流程不等同于微信支付商户 API。真实自动支付所需的商户接口、异步回调与密钥配置说明见 [微信收款码说明](docs/payments/wechat-personal-qr.md)。

## GitHub 源码范围与新环境配置

仓库包含前后端源码、运行脚本、项目文档和业务图片资源。历史归档、依赖及构建产物、本机运行记录、私密配置、原始业务数据库导出和个人微信收款码不上传；它们在当前电脑上保留。需要使用手动微信收款时，请自行在 `vue3/public/payment/wechat-personal-qr.jpg` 放置收款码并配置收款说明。

新环境需要 MySQL 8、Java 17、Node.js/npm；后端 Maven 配置见 `springboot/pom.xml`。现有启动脚本面向本机官方 MySQL 路径，不会自动安装依赖或构建项目；其他电脑请按自身路径准备依赖、构建后端和前端，再启动服务。数据库及 AI 服务凭据放在不入库的 `springboot/application-local.yml`，或设置对应环境变量。后端还使用 `SPRING_SECURITY_USER_PASSWORD`、`SPRING_MAIL_USERNAME`、`SPRING_MAIL_PASSWORD`、`KNIFE4J_BASIC_PASSWORD`、`JWT_SECRET`；可在本地配置中分别设置 `spring.security.user.password`、`spring.mail.username/password`、`knife4j.basic.password`、`jwt.secret`。JWT 密钥应自行生成足够长度的随机值，邮件账号和授权码按自己的服务配置。请勿将真实凭据提交到 GitHub。

`database/schema.sql` 只包含表结构，不包含用户、地址、订单、聊天或其他业务记录。首次部署时先创建全新的空库 `heritage_db`（MySQL 8、`utf8mb4`），再导入：

```sh
mysql -h 127.0.0.1 -P 3306 -u YOUR_DB_USER -p heritage_db < database/schema.sql
```

此操作仅适用于新空库，不会创建演示用户或业务数据。现有电脑继续使用当前数据库，无需重新导入；原始 `database/heritage_db.sql` 仅保留在本机，不能作为当前数据备份。
