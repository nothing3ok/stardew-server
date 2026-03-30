# Nothing Stardew Server

面向服务器部署的《Stardew Valley》Docker 方案，集成持久化存储、SMAPI 模组栈，以及浏览器管理面板。

[English](README.md)

## 项目概览

Nothing Stardew Server 将 Stardew Valley、SMAPI 和一组适合联机服务器的模组打包进 Docker 工作流，方便部署在 VPS、家用服务器或 NAS 上。

当前项目包含这些核心能力：

- 持久化保存存档、日志、备份、面板数据和自定义模组
- 浏览器 Web 面板，可查看状态、日志、配置、存档、备份和模组
- 存档上传、默认存档选择、备份创建、备份下载、删除和恢复相关流程
- Web 面板内的联机存档房主迁移
- 通过内置模组自动加载存档
- 可选 VNC，用于首次进入游戏时的手动初始化

## 内置组件

- Stardew Valley
- SMAPI
- Always On Server
- AutoHideHost
- ServerAutoLoad
- Skill Level Guard
- Web 管理面板，位于 `docker/web-panel`

## 端口说明

- `24642/udp`: 星露谷联机服务
- `5900/tcp`: VNC
- `9090/tcp`: Prometheus 指标
- `18642/tcp`: Web 管理面板

## 持久化数据目录

项目运行时数据保存在 `./data`：

- `data/saves`
- `data/game`
- `data/steam`
- `data/logs`
- `data/backups`
- `data/panel`
- `data/custom-mods`

## 部署方式

### 一键引导部署

如果你是在一台全新服务器上首次部署，推荐直接使用引导脚本。

英文版：

```bash
curl -fsSL https://raw.githubusercontent.com/nothing3ok/stardew-server/main/quick-start.sh | bash
```

中文版：

```bash
curl -fsSL https://raw.githubusercontent.com/nothing3ok/stardew-server/main/quick-start-zh.sh | bash
```

如果你已经 clone 了仓库，也可以直接运行：

```bash
./quick-start.sh
# 或
./quick-start-zh.sh
```

脚本会自动完成这些步骤：

- 检查 Docker 和 Docker Compose
- 创建 `.env`
- 引导输入 Steam 账号信息
- 创建必要的数据目录
- 修复目录权限
- 启动容器栈
- 提示 Steam Guard、VNC 和 Web 面板的后续操作

### 手动部署

如果你想完全掌控文件和部署过程，可以使用手动部署。

#### 1. 前置要求

- Docker
- Docker Compose
- 一个拥有 Stardew Valley 的 Steam 账号
- 至少 2 GB 内存
- 至少 2 GB 可用磁盘空间

#### 2. 克隆仓库

```bash
git clone https://github.com/nothing3ok/stardew-server.git
cd stardew-server
```

#### 3. 创建 `.env`

```bash
cp .env.example .env
```

然后编辑 `.env`，至少填写：

```env
STEAM_USERNAME=your_steam_username
STEAM_PASSWORD=your_steam_password
ENABLE_VNC=true
VNC_PASSWORD=stardew1
```

#### 4. 初始化数据目录

```bash
./init.sh
```

这个脚本会创建所需目录，并将权限修正为 `1000:1000`。

#### 5. 启动服务

```bash
docker compose up -d
```

#### 6. 查看启动日志

```bash
docker logs -f nothing-stardew
```

如果启用了 Steam Guard：

```bash
docker attach nothing-stardew
```

输入验证码后等待几秒，再用 `Ctrl+P Ctrl+Q` 分离容器，不要按 `Ctrl+C`。

## 首次启动后的初始化

容器启动后，通常可以通过以下两种方式完成后续初始化。

### 方式 1：Web 面板

访问：

```text
http://your-server-ip:18642
```

首次访问时，面板会要求你创建管理员密码。

当前 Web 面板支持：

- 仪表盘和运行状态
- 实时日志
- SMAPI 终端
- 存档列表与默认存档选择
- 存档上传
- 存档备份创建
- 备份下载
- 备份删除
- 存档删除
- 联机存档房主迁移
- 配置编辑
- 模组管理

### 方式 2：VNC

使用 VNC 客户端连接：

```text
your-server-ip:5900
```

密码使用 `.env` 中配置的 `VNC_PASSWORD`。

VNC 适合这些场景：

- 手动创建一个新的多人农场
- 在游戏内手动加载一次存档
- 可视化确认首次启动状态

完成第一次游戏内初始化后，后续重启通常都能通过内置模组自动加载。

## 存档与备份流程

当前项目支持这些常见操作：

- 上传存档压缩包或存档目录
- 为自动加载指定默认存档
- 在高风险操作前手动创建备份
- 从面板直接下载备份到本地
- 永久删除旧备份
- 删除不再需要的存档
- 对联机存档执行房主迁移

备份默认存放在：

```text
./data/backups
```

## 你们项目新增的能力

相对基础部署版本，当前仓库还补充了这些能力：

- 首次访问 Web 面板时引导设置管理员密码，并持久化保存认证数据
- 面板内上传存档压缩包、设置默认自动加载存档、直接下载备份
- 通过 `stardew-manager` 服务，让面板中的运行时配置修改可以触发真实重建或重启
- Prometheus 指标暴露在 `9090` 端口，便于接 Grafana 或其他监控系统
- 通过 `data/custom-mods/` 安装你自己的 SMAPI 模组，支持目录或 `.zip`
- 通过 `player-access.conf` 实现白名单或黑名单玩家访问控制
- 支持崩溃自动重启、自动备份、自定义公开加入地址、指定默认存档名
- 支持 Docker Secrets，从 `/run/secrets/` 读取 Steam 凭据，减少明文密码暴露

## 常用命令

启动：

```bash
docker compose up -d
```

重启：

```bash
docker compose restart
```

停止：

```bash
docker compose down
```

查看日志：

```bash
docker logs -f nothing-stardew
```

进入容器：

```bash
docker exec -it nothing-stardew bash
```

## 常见问题

### `Disk write failure`

通常是 `data/` 目录权限不正确导致的。

优先执行：

```bash
./init.sh
```

或者手动修复：

```bash
chown -R 1000:1000 data/
docker compose restart
```

### 玩家无法加入

- 检查 `24642/udp` 是否已开放
- 确认存档已经加载
- 确认客户端和服务端游戏版本一致

### Steam Guard 阻塞首次启动

附加到容器并输入验证码：

```bash
docker attach nothing-stardew
```

完成后用 `Ctrl+P Ctrl+Q` 分离，不要用 `Ctrl+C`。

## 说明

- 你必须合法拥有 Steam 版 Stardew Valley
- 本项目不是盗版分发工具
- VNC 协议限制密码最多 8 个字符
- 修改 `.env` 后，需要重启容器栈才能生效

## 许可证

MIT
