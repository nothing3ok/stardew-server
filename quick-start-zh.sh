#!/bin/bash
# =============================================================================
# Nothing Stardew Server - 快速启动脚本
# =============================================================================
# 此脚本将帮助您在几分钟内完成星露谷物语专用服务器的初始化。
# =============================================================================

# 不在错误时自动退出，由脚本自行处理错误
set +e

# 输出颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# =============================================================================
# 辅助函数
# =============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}==================================================================${NC}"
    echo -e "${CYAN}${BOLD}  Nothing Stardew Server - 快速启动${NC}"
    echo -e "${CYAN}${BOLD}==================================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[成功] $1${NC}"
}

print_error() {
    echo -e "${RED}[错误] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[警告] $1${NC}"
}

print_info() {
    echo -e "${BLUE}[信息] $1${NC}"
}

print_step() {
    echo ""
    echo -e "${BOLD}$1${NC}"
}

ask_question() {
    echo -e "${CYAN}[?] $1${NC}"
}

# Docker Compose 命令
COMPOSE_CMD=""

# =============================================================================
# 主要流程
# =============================================================================

check_docker() {
    print_step "步骤 1: 检查 Docker 安装..."

    if ! command -v docker &> /dev/null; then
        print_error "未检测到 Docker。"
        echo ""
        echo "请先运行以下命令安装 Docker："
        echo -e "  ${CYAN}curl -fsSL https://get.docker.com | sh${NC}"
        echo ""
        echo "其他系统请参考: https://docs.docker.com/get-docker/"
        echo ""
        exit 1
    fi

    if ! docker ps &> /dev/null; then
        print_error "Docker 守护进程未运行，或当前用户没有权限。"
        echo ""
        echo "您可以尝试以下方式："
        echo -e "  1. 启动 Docker: ${CYAN}sudo systemctl start docker${NC}"
        echo -e "  2. 将当前用户加入 docker 组: ${CYAN}sudo usermod -aG docker \$USER${NC}"
        echo "     完成后请重新登录终端。"
        echo ""
        exit 1
    fi

    if docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
        print_success "Docker 已可用，检测到 Docker Compose v2。"
    elif command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
        print_success "Docker 已可用，检测到 Docker Compose v1。"
    else
        print_warning "未检测到 Docker Compose，尝试自动安装..."
        echo ""

        INSTALL_SUCCESS=false

        if command -v apt-get &> /dev/null; then
            print_info "检测到 apt，正在安装 docker-compose-plugin..."
            if apt-get update -qq &> /dev/null && apt-get install -y -qq docker-compose-plugin &> /dev/null; then
                INSTALL_SUCCESS=true
            fi
        fi

        if [ "$INSTALL_SUCCESS" = "false" ] && command -v yum &> /dev/null; then
            print_info "检测到 yum，正在安装 docker-compose-plugin..."
            if yum install -y docker-compose-plugin &> /dev/null; then
                INSTALL_SUCCESS=true
            fi
        fi

        if [ "$INSTALL_SUCCESS" = "false" ] && command -v dnf &> /dev/null; then
            print_info "检测到 dnf，正在安装 docker-compose-plugin..."
            if dnf install -y docker-compose-plugin &> /dev/null; then
                INSTALL_SUCCESS=true
            fi
        fi

        if [ "$INSTALL_SUCCESS" = "true" ] && docker compose version &> /dev/null; then
            COMPOSE_CMD="docker compose"
            print_success "Docker Compose 自动安装成功。"
        else
            print_error "Docker Compose 自动安装失败。"
            echo ""
            print_info "请手动运行以下命令安装："
            echo ""
            if command -v apt-get &> /dev/null; then
                echo -e "  ${CYAN}sudo apt-get update && sudo apt-get install -y docker-compose-plugin${NC}"
            elif command -v yum &> /dev/null; then
                echo -e "  ${CYAN}sudo yum install -y docker-compose-plugin${NC}"
            else
                echo -e "  ${CYAN}sudo apt-get update && sudo apt-get install -y docker-compose-plugin${NC}"
            fi
            echo ""
            echo "安装完成后，请重新运行本脚本。"
            echo ""
            exit 1
        fi
    fi
}

download_files() {
    print_step "步骤 2: 下载配置文件..."

    if [ -f "docker-compose.yml" ] && [ -f ".env.example" ]; then
        print_success "当前目录已存在配置文件。"
        return
    fi

    if command -v git &> /dev/null; then
        print_info "正在克隆仓库..."
        git clone https://github.com/nothing3ok/stardew-server.git
        cd stardew-server
        print_success "仓库克隆完成。"
    else
        print_info "未检测到 git，改为直接下载文件..."

        if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
            print_error "系统中既没有 wget，也没有 curl。"
            echo "请先安装 git、wget 或 curl。"
            exit 1
        fi

        mkdir -p stardew-server
        cd stardew-server

        BASE_URL="https://raw.githubusercontent.com/nothing3ok/stardew-server/main"

        if command -v curl &> /dev/null; then
            curl -fsSL "$BASE_URL/docker-compose.yml" -o docker-compose.yml
            curl -fsSL "$BASE_URL/.env.example" -o .env.example
        else
            wget -q "$BASE_URL/docker-compose.yml" -O docker-compose.yml
            wget -q "$BASE_URL/.env.example" -O .env.example
        fi

        print_success "配置文件下载完成。"
    fi
}

configure_steam() {
    print_step "步骤 3: 配置 Steam 账号..."

    echo ""
    print_warning "重要：您必须在 Steam 上拥有 Stardew Valley。"
    print_info "游戏文件会通过您的 Steam 账号下载。"
    echo ""

    if [ -f ".env" ]; then
        ask_question ".env 文件已存在，是否重新配置？(y/n)"
        read -r reconfigure </dev/tty
        if [[ ! $reconfigure =~ ^[Yy]$ ]]; then
            print_info "继续使用现有 .env 文件。"
            return
        fi
    fi

    cp .env.example .env

    echo ""
    print_info "==================================================="
    print_info "  配置方式"
    print_info "==================================================="
    echo ""
    ask_question "是否现在在终端中手动输入配置？(y/n)"
    echo -e "${CYAN}  y${NC} - 立即输入 Steam 用户名、密码和 VNC 密码"
    echo -e "${CYAN}  n${NC} - 稍后手动编辑 .env 文件"
    echo ""
    read -r manual_input </dev/tty

    if [[ $manual_input =~ ^[Yy]$ ]]; then
        echo ""
        ask_question "请输入您的 Steam 用户名："
        read -r steam_username </dev/tty

        echo ""
        ask_question "请输入您的 Steam 密码（输入时不显示）："
        read -rs steam_password </dev/tty
        echo ""

        if [ -z "$steam_username" ] || [ -z "$steam_password" ]; then
            print_error "Steam 用户名和密码不能为空。"
            exit 1
        fi

        echo ""
        print_info "如果您启用了 Steam Guard，稍后还需要输入一次验证码。"
        print_info "建议准备好手机令牌或邮箱验证码。"

        echo ""
        ask_question "请输入 VNC 密码（最多 8 位，直接回车使用默认值 stardew1）："
        read -r vnc_password </dev/tty
        if [ -z "$vnc_password" ]; then
            vnc_password="stardew1"
        fi

        if [ ${#vnc_password} -gt 8 ]; then
            print_warning "VNC 密码超过 8 位，将自动截断。"
            print_warning "实际使用的密码为: ${vnc_password:0:8}"
            vnc_password="${vnc_password:0:8}"
        fi

        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/STEAM_USERNAME=.*/STEAM_USERNAME=$steam_username/" .env
            sed -i '' "s/STEAM_PASSWORD=.*/STEAM_PASSWORD=$steam_password/" .env
            sed -i '' "s/VNC_PASSWORD=.*/VNC_PASSWORD=$vnc_password/" .env
        else
            sed -i "s/STEAM_USERNAME=.*/STEAM_USERNAME=$steam_username/" .env
            sed -i "s/STEAM_PASSWORD=.*/STEAM_PASSWORD=$steam_password/" .env
            sed -i "s/VNC_PASSWORD=.*/VNC_PASSWORD=$vnc_password/" .env
        fi

        print_success "Steam 凭据已写入 .env。"
    else
        echo ""
        print_info "请手动编辑 .env 文件完成配置："
        echo -e "  ${CYAN}nano .env${NC}  或  ${CYAN}vim .env${NC}"
        echo ""
        print_info "至少需要填写以下字段："
        echo -e "  ${YELLOW}STEAM_USERNAME${NC}  - Steam 用户名"
        echo -e "  ${YELLOW}STEAM_PASSWORD${NC}  - Steam 密码"
        echo -e "  ${YELLOW}VNC_PASSWORD${NC}    - VNC 密码（最多 8 位）"
        echo ""
        ask_question "完成后按回车继续..."
        read -r </dev/tty
    fi
}

setup_directories() {
    print_step "步骤 4: 创建数据目录..."

    mkdir -p data/{saves,game,steam,logs,backups,custom-mods,panel}

    print_info "正在设置目录权限（UID 1000）..."

    if [ -w "data" ]; then
        chown -R 1000:1000 data/
    else
        print_info "当前用户权限不足，尝试使用 sudo..."
        sudo chown -R 1000:1000 data/
    fi

    if [ "$(stat -c '%u' data/game 2>/dev/null || stat -f '%u' data/game 2>/dev/null)" != "1000" ]; then
        print_error "目录权限设置失败。"
        print_error "这会导致游戏下载时出现 Disk write failure。"
        echo ""
        echo "请手动执行: sudo chown -R 1000:1000 data/"
        echo ""
        exit 1
    fi

    print_success "目录创建完成，权限设置完成。"
}

start_server() {
    print_step "步骤 5: 启动服务器..."

    echo ""
    print_info "正在拉取 Docker 镜像，这可能需要几分钟..."
    $COMPOSE_CMD pull

    echo ""
    print_info "正在启动服务..."
    $COMPOSE_CMD up -d

    print_success "服务启动命令已执行。"

    print_info "等待初始化容器完成..."
    for i in {1..30}; do
        INIT_STATUS=$(docker inspect --format='{{.State.Status}}' nothing-stardew-init 2>/dev/null)
        if [ "$INIT_STATUS" = "exited" ]; then
            INIT_EXIT=$(docker inspect --format='{{.State.ExitCode}}' nothing-stardew-init 2>/dev/null)
            if [ "$INIT_EXIT" = "0" ]; then
                print_success "初始化容器执行成功。"
                break
            else
                print_error "初始化容器执行失败，退出码: $INIT_EXIT"
                echo "请查看日志: docker logs nothing-stardew-init"
                exit 1
            fi
        fi
        sleep 1
    done

    echo ""
    print_info "等待服务器完成初始化（5 秒）..."
    sleep 5

    if ! docker ps | grep -q nothing-stardew; then
        print_error "容器未成功启动。"
        echo ""
        echo "请查看日志: docker logs nothing-stardew"
        exit 1
    fi

    print_success "服务器正在运行。"
}

get_server_ip() {
    if command -v curl &> /dev/null; then
        public_ip=$(curl -4 -s ifconfig.me 2>/dev/null || curl -4 -s ip.sb 2>/dev/null || echo "")
        if [ -n "$public_ip" ]; then
            echo "$public_ip"
            return
        fi
    fi

    if command -v hostname &> /dev/null; then
        hostname -I 2>/dev/null | awk '{print $1}' || echo "your-server-ip"
    else
        echo "your-server-ip"
    fi
}

print_next_steps() {
    echo ""
    echo -e "${GREEN}${BOLD}部署完成，接下来您可以这样做：${NC}"
    echo ""

    echo -e "${BOLD}1. 查看下载进度：${NC}"
    echo "   docker logs -f nothing-stardew"
    echo ""
    echo -e "${YELLOW}   首次启动会下载约 1.5GB 游戏文件。${NC}"
    echo -e "${YELLOW}   一般需要 5 到 15 分钟，取决于网络速度。${NC}"
    echo ""

    echo -e "${BOLD}2. 如果启用了 Steam Guard：${NC}"
    echo "   - 先检查日志中是否出现验证码提示："
    echo -e "     ${CYAN}docker logs nothing-stardew | grep -i \"steam guard\"${NC}"
    echo "   - 如果出现 \"Steam Guard code:\"，请附加到容器："
    echo -e "     ${CYAN}docker attach nothing-stardew${NC}"
    echo "   - 输入您收到的验证码并回车"
    echo -e "   - ${YELLOW}注意：${NC}输入后等待 3 到 5 秒，确认游戏下载开始"
    echo -e "   - 然后按 ${YELLOW}Ctrl+P Ctrl+Q${NC} 分离，不要按 ${RED}Ctrl+C${NC}"
    echo ""

    echo -e "${BOLD}3. Web 管理面板：${NC}"
    echo -e "   - 浏览器访问: ${CYAN}http://$(get_server_ip):18642${NC}"
    echo "   - 首次访问会引导您设置管理员密码"
    echo "   - 可用于查看状态、日志、终端、配置、存档和模组"
    echo ""

    echo -e "${BOLD}4. 可选的 VNC 连接：${NC}"
    echo "   - 安装一个 VNC 客户端，如 RealVNC 或 TightVNC"
    echo -e "   - 连接地址: ${CYAN}$(get_server_ip):5900${NC}"
    echo -e "   - 密码: ${CYAN}$(grep VNC_PASSWORD .env | cut -d'=' -f2)${NC}"
    echo "   - 如果您想手动进游戏创建新存档，可以使用 VNC"
    echo "   - 也可以直接通过 Web 面板上传已有存档"
    echo ""

    echo -e "${BOLD}5. 玩家连接方式：${NC}"
    echo "   - 打开 Stardew Valley"
    echo "   - 进入 \"合作\" -> \"加入局域网游戏\""
    echo "   - 游戏通常会自动发现服务器，也可以手动输入服务器 IP"
    echo -e "   ${YELLOW}[提示] 默认使用 24642 端口，一般只填 IP 即可${NC}"
    echo ""

    echo -e "${BOLD}常用命令：${NC}"
    echo -e "   查看日志:      ${CYAN}docker logs -f nothing-stardew${NC}"
    echo -e "   重启服务:      ${CYAN}$COMPOSE_CMD down && $COMPOSE_CMD up -d${NC}"
    echo -e "   停止服务:      ${CYAN}$COMPOSE_CMD down${NC}"
    echo -e "   健康检查:      ${CYAN}./health-check.sh${NC}"
    echo -e "   备份存档:      ${CYAN}./backup.sh${NC}"
    echo ""
    echo -e "${YELLOW}   [提示] 修改 .env 后需要重启服务才会生效${NC}"
    echo ""

    echo -e "${GREEN}${BOLD}祝您使用愉快，享受您的 Nothing Stardew Server。${NC}"
    echo ""

    echo ""
    print_info "正在检测服务器状态..."
    sleep 2

    NEEDS_STEAM_GUARD=false
    RECENT_LOGS=$(docker logs --tail 50 nothing-stardew 2>&1 || true)
    if echo "$RECENT_LOGS" | grep -qi "steam guard\|two-factor\|two factor\|auth code\|verification code\|Enter the current code"; then
        NEEDS_STEAM_GUARD=true
    fi

    if [ "$NEEDS_STEAM_GUARD" = "true" ]; then
        echo ""
        print_warning "======================================================="
        print_warning "  检测到 Steam Guard 验证码流程"
        print_warning "======================================================="
        echo ""
        print_info "请按照以下步骤完成验证："
        echo -e "  ${CYAN}1.${NC} 运行: ${CYAN}docker attach nothing-stardew${NC}"
        echo -e "  ${CYAN}2.${NC} 输入收到的验证码并回车"
        echo -e "  ${CYAN}3.${NC} 等待 3 到 5 秒确认下载开始"
        echo -e "  ${CYAN}4.${NC} 按 ${YELLOW}Ctrl+P Ctrl+Q${NC} 分离容器，不要按 ${RED}Ctrl+C${NC}"
        echo ""
    else
        echo ""
        ask_question "下一步您想执行什么？"
        echo -e "  ${CYAN}1${NC} - 查看实时日志: ${CYAN}docker logs -f nothing-stardew${NC}"
        echo -e "  ${CYAN}2${NC} - 附加到容器: ${CYAN}docker attach nothing-stardew${NC}"
        echo ""
        print_info "您可以直接复制上面的命令到终端执行。"
    fi
}

# =============================================================================
# 主入口
# =============================================================================

main() {
    print_header
    check_docker
    download_files
    configure_steam
    setup_directories
    start_server
    print_next_steps
}

main
