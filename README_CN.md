# Puppy Stardew Server

一个面向《星露谷物语》多人联机的 Docker 化服务器项目，带持久化数据目录、内置 SMAPI 模组，以及可直接在浏览器里操作的 Web 管理面板。

[English](README.md)

## 项目简介

Puppy Stardew Server 把 Stardew Valley、SMAPI 和一组适合服务器场景的模组打包进 Docker 工作流，适合部署在云服务器、家用主机或 NAS 上。

当前项目已经包含：

- 存档、日志、备份、面板数据、自定义模组的持久化
- Web 面板管理状态、日志、配置、存档、备份和模组
- 存档上传、备份、下载、删除等常用操作
- 联机存档的 Host Migration 功能
- 通过内置模组自动加载存档
- 首次进游戏时可选的 VNC 远程桌面

## 内置组件

- Stardew Valley
- SMAPI
- Always On Server
- AutoHideHost
- ServerAutoLoad
- Skill Level Guard
- Web 面板 `docker/web-panel`

## 默认端口

- `24642/udp`：星露谷联机端口
- `5900/tcp`：VNC 远程桌面
- `9090/tcp`：Prometheus 指标
- `18642/tcp`：Web 面板

## 持久化目录

项目运行时数据默认保存在 `./data` 下：

- `data/saves`
- `data/game`
- `data/steam`
- `data/logs`
- `data/backups`
- `data/panel`
- `data/custom-mods`

## 部署方式

### 自动部署

如果你希望脚本帮你完成初始化，直接使用仓库自带脚本。

英文引导脚本：

```bash
./quick-start.sh
```

中文引导脚本：

```bash
./quick-start-zh.sh
```

脚本会自动完成这些事情：

- 检查 Docker 和 Docker Compose
- 创建 `.env`
- 引导填写 Steam 账号
- 创建数据目录
- 修正目录权限
- 启动服务
- 输出 Steam Guard、VNC 和 Web 面板的下一步说明

### 手动部署

如果你希望自己掌控每一步，使用手动方式。

#### 1. 前置要求

- 已安装 Docker
- 已安装 Docker Compose
- 一个已经购买 Stardew Valley 的 Steam 账号
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

然后编辑 `.env`，至少填写这些字段：

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

这一步会创建所需目录，并把权限设置为 `1000:1000`。

#### 5. 启动服务

```bash
docker compose up -d
```

#### 6. 查看启动日志

```bash
docker logs -f puppy-stardew
```

如果启用了 Steam Guard：

```bash
docker attach puppy-stardew
```

输入验证码后等待几秒，再按 `Ctrl+P Ctrl+Q` 退出附着。

## 首次启动后的使用方式

容器启动后，通常有两种管理方式。

### 方式 1：Web 面板

浏览器访问：

```text
http://你的服务器IP:18642
```

第一次访问会要求你创建管理员密码。

当前 Web 面板已经支持：

- 仪表盘和运行状态查看
- 实时日志
- SMAPI 终端
- 存档列表和默认存档选择
- 存档上传
- 存档备份
- 备份下载到本地
- 备份永久删除
- 存档删除
- 联机存档 Host Migration
- 配置编辑
- 模组管理

### 方式 2：VNC

用 VNC 客户端连接：

```text
你的服务器IP:5900
```

密码使用 `.env` 里的 `VNC_PASSWORD`。

VNC 适合这些场景：

- 手动创建一个新的联机农场
- 手动在游戏里加载旧存档
- 第一次开服时做可视化确认

完成首次设置后，后续重启通常可以依靠内置模组自动加载存档。

## 存档和备份能力

当前项目在 Web 面板里支持这些存档相关操作：

- 上传存档压缩包或存档目录包
- 选择默认自动加载的存档
- 在高风险操作前自动创建备份
- 把备份下载到本地电脑
- 永久删除备份
- 在面板内删除存档
- 对联机存档执行 Host Migration

备份文件默认保存位置：

```text
./data/backups
```

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
docker logs -f puppy-stardew
```

进入容器：

```bash
docker exec -it puppy-stardew bash
```

## 故障排查

### 下载游戏时报 `Disk write failure`

通常是 `data/` 目录权限不对。

先执行：

```bash
./init.sh
```

或者手动修复：

```bash
chown -R 1000:1000 data/
docker compose restart
```

### 玩家无法加入

- 检查 `24642/udp` 是否放行
- 确认存档已经成功加载
- 确认客户端和服务端游戏版本一致

### Steam Guard 阻塞首次启动

附着到容器后输入验证码：

```bash
docker attach puppy-stardew
```

退出时使用 `Ctrl+P Ctrl+Q`，不要用 `Ctrl+C`。

## 说明

- 你必须合法拥有 Steam 版 Stardew Valley
- 本项目不是盗版工具
- VNC 协议只支持最多 8 位密码
- 修改 `.env` 后需要重启容器才会生效

## 许可证

MIT
