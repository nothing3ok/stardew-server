# Contributing to Nothing Stardew Server

感谢你关注 Nothing Stardew Server。

这份文档介绍如何提交问题、准备修复、运行测试，以及向项目提交 Pull Request。

## 提交问题

### 报告 Bug

如果你发现 Bug，建议按下面的顺序整理信息：

1. 先搜索现有 Issue，确认是否已经有人报告过同样的问题。
2. 尽量提供可复现步骤。
3. 附上关键日志、配置片段和运行环境信息。

建议附带的信息：

- 容器日志：`docker logs nothing-stardew > logs.txt`
- Docker 版本：`docker --version`
- 使用的部署方式和系统版本
- 相关的 `docker-compose.yml` 或 `.env` 配置差异

### 功能建议

如果你想提交功能建议，请尽量说明：

- 想解决什么具体问题
- 你期待的使用方式
- 是否会影响现有部署或兼容性

## Pull Request 流程

1. Fork 仓库
2. 从 `main` 创建新分支，例如：`git checkout -b feature/my-feature`
3. 完成修改并自测
4. 提交清晰的 commit message
5. 推送分支到你的 Fork
6. 发起 Pull Request

提交 PR 前，建议确认：

- 改动范围尽量聚焦
- 说明清楚改了什么、为什么改
- 如果修复了 Issue，描述中带上对应编号
- 如果改动影响部署、配置或文档，同时更新相关说明

## 本地开发与测试

```bash
# 1. 克隆仓库
git clone https://github.com/nothing3ok/stardew-server.git
cd stardew-server

# 2. 配置测试用 Steam 账号
export STEAM_USERNAME="your_test_account"
export STEAM_PASSWORD="your_password"

# 3. 构建测试镜像
docker build -t test-stardew:dev -f docker/Dockerfile docker/

# 4. 运行测试脚本
./tests/test-steam-guard.sh
```

你也可以使用下面这些辅助脚本：

```bash
# 验证部署
./verify-deployment.sh

# 清理测试环境
./tests/cleanup-tests.sh
```

## 代码风格

### Shell 脚本

推荐风格：

```bash
function_name() {
    local variable="$1"

    if [ -z "$variable" ]; then
        log_error "Variable is empty"
        return 1
    fi

    echo "$variable"
}
```

建议：

- 优先保持脚本简单、可读、易排查
- 变量尽量加引号
- 错误提示尽量明确
- 修改用户可见输出时，注意终端兼容性和编码问题

### Dockerfile

推荐风格：

```dockerfile
RUN apt-get update && \
    apt-get install -y package && \
    rm -rf /var/lib/apt/lists/*
```

建议：

- 尽量减少无用层
- 安装后清理缓存
- 避免不必要地使用 `latest`

## Commit Message 建议

推荐格式：

```text
type(scope): short summary
```

常见类型：

- `feat`: 新功能
- `fix`: 修复问题
- `docs`: 文档修改
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 杂项维护

示例：

```text
fix(entrypoint): preserve stdin for Steam Guard input
```

如果需要，也可以在提交说明或 PR 描述里补充背景，例如：

```text
Steam Guard input was blocked by pipe redirection.
Removed the pipe to preserve stdin for interactive input.

Fixes: #42
```

## 提交前检查

发起 PR 前建议至少确认：

- [ ] 相关脚本已自测
- [ ] 文档和提示文本同步更新
- [ ] 新增功能有对应说明
- [ ] 修改不会明显破坏现有部署流程
- [ ] 用户可见输出没有乱码

## 相关文档

- [README.md](README.md)
- [README_CN.md](README_CN.md)
- `DEVELOPMENT.md`（如果后续补充）

## 获取帮助

如果你在开发或部署时遇到问题，可以优先查看：

1. GitHub Issues
2. 容器日志：`docker logs nothing-stardew`
3. 项目 README 和部署脚本输出

## License

向本项目提交代码、文档或脚本改动，即表示你同意这些贡献将遵循项目当前使用的 MIT License。
