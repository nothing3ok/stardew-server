#!/bin/bash
# =============================================================================
# Puppy Stardew Server - 蹇€熷惎鍔ㄨ剼鏈紙涓枃鐗堬級
# =============================================================================
# 姝よ剼鏈皢甯姪鎮ㄥ湪鍑犲垎閽熷唴璁剧疆鏄熼湶璋风墿璇笓鐢ㄦ湇鍔″櫒锛?
# =============================================================================

# 涓嶅湪閿欒鏃堕€€鍑?- 鎴戜滑鎵嬪姩澶勭悊閿欒
set +e

# 杈撳嚭棰滆壊
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # 鏃犻鑹?
BOLD='\033[1m'

# =============================================================================
# 杈呭姪鍑芥暟
# =============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣${NC}"
    echo -e "${CYAN}${BOLD}  馃惗 灏忕嫍鏄熻胺鏈嶅姟鍣?- 蹇€熷惎鍔?{NC}"
    echo -e "${CYAN}${BOLD}鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}鉁?$1${NC}"
}

print_error() {
    echo -e "${RED}鉂?$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}鈿狅笍  $1${NC}"
}

print_info() {
    echo -e "${BLUE}鈩癸笍  $1${NC}"
}

print_step() {
    echo ""
    echo -e "${BOLD}$1${NC}"
}

ask_question() {
    echo -e "${CYAN}鉂?$1${NC}"
}

# Docker Compose 鍛戒护锛堝叏灞€鍙橀噺锛屽湪 check_docker 涓缃級
COMPOSE_CMD=""

# =============================================================================
# 涓昏璁剧疆鍑芥暟
# =============================================================================

check_docker() {
    print_step "姝ラ 1: 妫€鏌?Docker 瀹夎..."

    if ! command -v docker &> /dev/null; then
        print_error "Docker 鏈畨瑁咃紒"
        echo ""
        echo "璇疯繍琛屼互涓嬪懡浠ゅ畨瑁?Docker锛?
        echo -e "  ${CYAN}curl -fsSL https://get.docker.com | sh${NC}"
        echo ""
        echo "鍏朵粬绯荤粺璇疯闂? https://docs.docker.com/get-docker/"
        echo ""
        exit 1
    fi

    if ! docker ps &> /dev/null; then
        print_error "Docker 瀹堟姢杩涚▼鏈繍琛屾垨闇€瑕?sudo 鏉冮檺锛?
        echo ""
        echo "灏濊瘯浠ヤ笅鏂规硶涔嬩竴锛?
        echo -e "  1. 鍚姩 Docker: ${CYAN}sudo systemctl start docker${NC}"
        echo -e "  2. 灏嗙敤鎴锋坊鍔犲埌 docker 缁? ${CYAN}sudo usermod -aG docker \$USER${NC}"
        echo "     (鐒跺悗娉ㄩ攢骞堕噸鏂扮櫥褰?"
        echo ""
        exit 1
    fi

    # 妫€娴?Docker Compose 鍙敤鎬?
    if docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
        print_success "Docker 宸插畨瑁呭苟姝ｅ湪杩愯锛侊紙Docker Compose v2锛?
    elif command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
        print_success "Docker 宸插畨瑁呭苟姝ｅ湪杩愯锛侊紙Docker Compose v1锛?
    else
        # 灏濊瘯鑷姩瀹夎 docker-compose-plugin
        print_warning "Docker Compose 鏈畨瑁咃紝姝ｅ湪灏濊瘯鑷姩瀹夎..."
        echo ""

        INSTALL_SUCCESS=false

        # 鏂规硶 1: apt (Ubuntu/Debian)
        if command -v apt-get &> /dev/null; then
            print_info "妫€娴嬪埌 apt 鍖呯鐞嗗櫒锛屾鍦ㄥ畨瑁?docker-compose-plugin..."
            if apt-get update -qq &> /dev/null && apt-get install -y -qq docker-compose-plugin &> /dev/null; then
                INSTALL_SUCCESS=true
            fi
        fi

        # 鏂规硶 2: yum (CentOS/RHEL)
        if [ "$INSTALL_SUCCESS" = "false" ] && command -v yum &> /dev/null; then
            print_info "妫€娴嬪埌 yum 鍖呯鐞嗗櫒锛屾鍦ㄥ畨瑁?docker-compose-plugin..."
            if yum install -y docker-compose-plugin &> /dev/null; then
                INSTALL_SUCCESS=true
            fi
        fi

        # 鏂规硶 3: dnf (Fedora)
        if [ "$INSTALL_SUCCESS" = "false" ] && command -v dnf &> /dev/null; then
            print_info "妫€娴嬪埌 dnf 鍖呯鐞嗗櫒锛屾鍦ㄥ畨瑁?docker-compose-plugin..."
            if dnf install -y docker-compose-plugin &> /dev/null; then
                INSTALL_SUCCESS=true
            fi
        fi

        # 楠岃瘉瀹夎缁撴灉
        if [ "$INSTALL_SUCCESS" = "true" ] && docker compose version &> /dev/null; then
            COMPOSE_CMD="docker compose"
            print_success "Docker Compose 宸茶嚜鍔ㄥ畨瑁呮垚鍔燂紒"
        else
            # 鑷姩瀹夎澶辫触锛岀粰鍑哄叿浣撶殑鎵嬪姩瀹夎鍛戒护
            print_error "Docker Compose 鑷姩瀹夎澶辫触锛?
            echo ""
            print_info "璇锋墜鍔ㄨ繍琛屼互涓嬪懡浠ゅ畨瑁咃細"
            echo ""
            if command -v apt-get &> /dev/null; then
                echo -e "  ${CYAN}sudo apt-get update && sudo apt-get install -y docker-compose-plugin${NC}"
            elif command -v yum &> /dev/null; then
                echo -e "  ${CYAN}sudo yum install -y docker-compose-plugin${NC}"
            else
                echo -e "  ${CYAN}sudo apt-get update && sudo apt-get install -y docker-compose-plugin${NC}"
            fi
            echo ""
            echo "瀹夎瀹屾垚鍚庯紝閲嶆柊杩愯姝よ剼鏈嵆鍙€?
            echo ""
            exit 1
        fi
    fi
}

download_files() {
    print_step "姝ラ 2: 涓嬭浇閰嶇疆鏂囦欢..."

    if [ ! -d "stardew-server" ]; then
        print_info "鍏嬮殕浠撳簱..."
        if git clone https://github.com/nothing3ok/stardew-server.git; then
            print_success "浠撳簱宸插厠闅嗭紒"
        else
            print_error "鍏嬮殕澶辫触锛佽妫€鏌ョ綉缁滆繛鎺ャ€?
            exit 1
        fi
    else
        print_info "鐩綍宸插瓨鍦紝璺宠繃鍏嬮殕"
    fi

    cd stardew-server || exit 1
}

configure_steam() {
    print_step "姝ラ 3: Steam 閰嶇疆..."
    echo ""
    print_warning "閲嶈锛氭偍蹇呴』鍦?Steam 涓婃嫢鏈夋槦闇茶胺鐗╄锛?
    print_info "娓告垙鏂囦欢灏嗛€氳繃鎮ㄧ殑 Steam 璐︽埛涓嬭浇銆?
    echo ""

    if [ -f ".env" ]; then
        ask_question ".env 鏂囦欢宸插瓨鍦ㄣ€傛槸鍚﹁閲嶆柊閰嶇疆锛?y/n)"
        read -r reconfigure </dev/tty
        if [[ ! $reconfigure =~ ^[Yy]$ ]]; then
            print_info "浣跨敤鐜版湁 .env 鏂囦欢"
            return
        fi
    fi

    cp .env.example .env

    echo ""
    print_info "鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?
    print_info "  閰嶇疆鏂瑰紡閫夋嫨"
    print_info "鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?
    echo ""
    ask_question "鏄惁鍦ㄧ粓绔墜鍔ㄨ緭鍏ラ厤缃俊鎭紵(y/n)"
    echo -e "${CYAN}  y${NC} - 鐜板湪鍦ㄧ粓绔緭鍏?Steam 鐢ㄦ埛鍚嶃€佸瘑鐮佸拰 VNC 瀵嗙爜"
    echo -e "${CYAN}  n${NC} - 绋嶅悗鎵嬪姩缂栬緫 .env 鏂囦欢锛堟帹鑽愮啛鎮?Linux 鐢ㄦ埛锛?
    echo ""
    read -r manual_input </dev/tty

    if [[ $manual_input =~ ^[Yy]$ ]]; then
        # 鎵嬪姩杈撳叆妯″紡
        echo ""
        ask_question "璇疯緭鍏ユ偍鐨?Steam 鐢ㄦ埛鍚嶏細"
        read -r steam_username </dev/tty

        echo ""
        ask_question "璇疯緭鍏ユ偍鐨?Steam 瀵嗙爜锛堣緭鍏ユ椂涓嶄細鏄剧ず锛岀洿鎺ヨ緭鍏ュ悗鎸夊洖杞︼級锛?
        read -rs steam_password </dev/tty
        echo ""

        echo ""
        ask_question "璇疯緭鍏?VNC 瀵嗙爜锛堟渶澶?涓瓧绗︼紝鎸夊洖杞︿娇鐢ㄩ粯璁?'stardew1'锛夛細"
        read -r vnc_password </dev/tty
        if [ -z "$vnc_password" ]; then
            vnc_password="stardew1"
        fi

        # 楠岃瘉骞舵埅鏂?VNC 瀵嗙爜涓?8 涓瓧绗?
        if [ ${#vnc_password} -gt 8 ]; then
            print_warning "VNC 瀵嗙爜瓒呰繃 8 涓瓧绗︼紒"
            print_warning "VNC 鍗忚浼氳嚜鍔ㄦ埅鏂负锛?{vnc_password:0:8}"
            vnc_password="${vnc_password:0:8}"
        fi

        # 鏇存柊 .env 鏂囦欢
        sed -i "s/^STEAM_USERNAME=.*/STEAM_USERNAME=$steam_username/" .env
        sed -i "s/^STEAM_PASSWORD=.*/STEAM_PASSWORD=$steam_password/" .env
        sed -i "s/^VNC_PASSWORD=.*/VNC_PASSWORD=$vnc_password/" .env

        print_success "Steam 閰嶇疆宸蹭繚瀛橈紒"
    else
        # 鎵嬪姩缂栬緫 .env 鏂囦欢妯″紡
        echo ""
        print_info "璇锋墜鍔ㄧ紪杈?.env 鏂囦欢鏉ラ厤缃偍鐨勫嚟璇侊細"
        echo -e "  ${CYAN}nano .env${NC}  鎴? ${CYAN}vim .env${NC}"
        echo ""
        print_info "闇€瑕侀厤缃互涓嬪瓧娈碉細"
        echo -e "  ${YELLOW}STEAM_USERNAME${NC}  - 鎮ㄧ殑 Steam 鐢ㄦ埛鍚?
        echo -e "  ${YELLOW}STEAM_PASSWORD${NC}  - 鎮ㄧ殑 Steam 瀵嗙爜"
        echo -e "  ${YELLOW}VNC_PASSWORD${NC}    - VNC 璁块棶瀵嗙爜锛堟渶澶?涓瓧绗︼級"
        echo ""
        ask_question "閰嶇疆瀹屾垚鍚庯紝鎸夊洖杞︾户缁?.."
        read -r </dev/tty
    fi
}

setup_directories() {
    print_step "姝ラ 4: 璁剧疆鏁版嵁鐩綍..."

    # 鍒涘缓鐩綍锛堝寘鎷棩蹇楃洃鎺ч渶瑕佺殑 logs 鐩綍锛?
    mkdir -p data/{saves,game,steam,logs,backups,custom-mods,panel}

    print_info "璁剧疆姝ｇ‘鐨勬潈闄?(UID 1000)..."
    if chown -R 1000:1000 data/ 2>/dev/null; then
        # 楠岃瘉鏉冮檺鏄惁姝ｇ‘璁剧疆
        if [ "$(stat -c '%u' data/game 2>/dev/null || stat -f '%u' data/game 2>/dev/null)" != "1000" ]; then
            print_error "鏉冮檺璁剧疆澶辫触锛?
            print_error "杩欏皢瀵艰嚧涓嬭浇娓告垙鏂囦欢鏃跺嚭鐜?纾佺洏鍐欏叆澶辫触'閿欒銆?
            echo ""
            echo "璇锋墜鍔ㄨ繍琛? sudo chown -R 1000:1000 data/"
            echo ""
            exit 1
        fi
        print_success "鐩綍宸插垱寤哄苟璁剧疆鏉冮檺锛?
    else
        print_warning "鏃犳硶璁剧疆鏉冮檺锛屽皾璇曚娇鐢?sudo..."
        if sudo chown -R 1000:1000 data/; then
            print_success "鐩綍宸插垱寤哄苟璁剧疆鏉冮檺锛?
        else
            print_error "璁剧疆鏉冮檺澶辫触锛?
            print_error "杩欏皢瀵艰嚧涓嬭浇娓告垙鏂囦欢鏃跺嚭鐜?纾佺洏鍐欏叆澶辫触'閿欒銆?
            echo ""
            echo "璇锋墜鍔ㄨ繍琛? sudo chown -R 1000:1000 data/"
            echo ""
            exit 1
        fi
    fi
}

start_server() {
    print_step "姝ラ 5: 鍚姩鏈嶅姟鍣?.."
    echo ""

    print_info "鎷夊彇 Docker 闀滃儚锛堝彲鑳介渶瑕佸嚑鍒嗛挓锛?.."
    echo ""
    # 鏄剧ず鎷夊彇杩涘害
    if $COMPOSE_CMD pull; then
        print_success "闀滃儚鎷夊彇瀹屾垚锛?
    else
        print_warning "鎷夊彇闀滃儚鏃跺嚭鐜伴敊璇紝灏濊瘯鍚姩..."
    fi

    echo ""
    print_info "鍚姩鏈嶅姟鍣?.."
    if $COMPOSE_CMD up -d; then
        print_success "鏈嶅姟鍣ㄥ凡鍚姩锛?
    else
        print_error "鍚姩澶辫触锛?
        echo ""
        echo "鏌ョ湅鏃ュ織浠ヤ簡瑙ｈ鎯?"
        echo -e "  ${CYAN}$COMPOSE_CMD logs${NC}"
        exit 1
    fi

    # 绛夊緟鍒濆鍖栧鍣ㄥ畬鎴?
    print_info "绛夊緟鍒濆鍖栧鍣ㄥ畬鎴?.."
    for i in {1..30}; do
        INIT_STATUS=$(docker inspect --format='{{.State.Status}}' nothing-stardew-init 2>/dev/null)
        if [ "$INIT_STATUS" = "exited" ]; then
            INIT_EXIT=$(docker inspect --format='{{.State.ExitCode}}' nothing-stardew-init 2>/dev/null)
            if [ "$INIT_EXIT" = "0" ]; then
                print_success "鍒濆鍖栧鍣ㄥ凡瀹屾垚锛?
                break
            else
                print_error "鍒濆鍖栧鍣ㄥけ璐ワ紙閫€鍑虹爜锛?INIT_EXIT锛夛紒"
                echo "鏌ョ湅鏃ュ織: docker logs nothing-stardew-init"
                exit 1
            fi
        fi
        sleep 1
    done

    print_info "绛夊緟鏈嶅姟鍣ㄥ垵濮嬪寲锛?绉掞級..."
    sleep 5

    if docker ps | grep -q nothing-stardew; then
        print_success "鏈嶅姟鍣ㄦ鍦ㄨ繍琛岋紒"
    else
        print_error "瀹瑰櫒鍚姩澶辫触锛?
        echo ""
        echo "鏌ョ湅鏃ュ織:"
        echo -e "  ${CYAN}docker logs nothing-stardew${NC}"
        exit 1
    fi
}

get_server_ip() {
    # 灏濊瘯鑾峰彇鍏綉 IP
    if command -v curl &> /dev/null; then
        public_ip=$(curl -4 -s ifconfig.me 2>/dev/null || curl -4 -s ip.sb 2>/dev/null || echo "")
        if [ -n "$public_ip" ]; then
            echo "$public_ip"
            return
        fi
    fi

    # 鍥為€€鍒版湰鍦?IP
    if command -v hostname &> /dev/null; then
        hostname -I 2>/dev/null | awk '{print $1}' || echo "your-server-ip"
    else
        echo "your-server-ip"
    fi
}

print_next_steps() {
    echo ""
    echo -e "${GREEN}${BOLD}馃帀 璁剧疆瀹屾垚锛佹帴涓嬫潵璇ュ仛浠€涔堬細${NC}"
    echo ""

    echo -e "${BOLD}1. 鐩戞帶涓嬭浇杩涘害锛?{NC}"
    echo "   docker logs -f nothing-stardew"
    echo ""
    echo -e "${YELLOW}   棣栨鍚姩灏嗕笅杞界害 1.5GB 娓告垙鏂囦欢銆?{NC}"
    echo -e "${YELLOW}   鏍规嵁鎮ㄧ殑缃戠粶閫熷害锛岄€氬父闇€瑕?5-15 鍒嗛挓銆?{NC}"
    echo ""

    echo -e "${BOLD}2. 濡傛灉鍚敤浜?Steam 浠ょ墝锛?{NC}"
    echo "   - 妫€鏌ユ棩蹇椾腑鏄惁鏈夎姹傝緭鍏ヤ护鐗屼唬鐮佺殑娑堟伅锛?
    echo -e "     ${CYAN}docker logs nothing-stardew | grep -i \"steam guard\"${NC}"
    echo "   - 濡傛灉鐪嬪埌 \"Steam Guard code:\" 鎻愮ず锛岄檮鍔犲埌瀹瑰櫒锛?
    echo -e "     ${CYAN}docker attach nothing-stardew${NC}"
    echo "   - 杈撳叆浠庨偖浠?鎵嬫満搴旂敤鑾峰彇鐨?Steam 浠ょ墝浠ｇ爜骞舵寜鍥炶溅"
    echo -e "   - ${YELLOW}閲嶈锛?{NC}杈撳叆鍚庣瓑寰?-5绉掞紝纭寮€濮嬩笅杞芥父鎴?
    echo -e "   - 鐒跺悗鎸?${YELLOW}Ctrl+P Ctrl+Q${NC} 鍒嗙锛?{RED}涓嶈鎸?Ctrl+C锛?{NC}锛?
    echo ""

    echo -e "${BOLD}3. 馃寪 Web 绠＄悊闈㈡澘锛堟帹鑽愶級锛?{NC}"
    echo -e "   - 娴忚鍣ㄨ闂? ${CYAN}http://$(get_server_ip):18642${NC}"
    echo "   - 棣栨璁块棶浼氬紩瀵间綘鍒涘缓绠＄悊瀵嗙爜"
    echo "   - 鍔熻兘: 瀹炴椂鐘舵€併€佹棩蹇楁煡鐪嬨€佺粓绔帶鍒躲€侀厤缃€佸瓨妗ｃ€佹ā缁勭鐞?
    echo ""

    echo -e "${BOLD}4. 鍙€夌殑 VNC 鍒濆璁剧疆锛堜粎鍦ㄩ渶瑕佹墜鍔ㄨ繘娓告垙鏃朵娇鐢級锛?{NC}"
    echo "   - 涓嬭浇 VNC 瀹㈡埛绔紙RealVNC銆乀ightVNC 绛夛級"
    echo -e "   - 杩炴帴鍒? ${CYAN}$(get_server_ip):5900${NC}"
    echo -e "   - 瀵嗙爜: ${CYAN}$(grep VNC_PASSWORD .env 2>/dev/null | cut -d'=' -f2 || echo 'stardew123')${NC}"
    echo "   - 濡傛灉浣犳兂鎵嬪姩鍦ㄦ父鎴忓唴鍒涘缓鏂板瓨妗ｏ紝鍙互浣跨敤 VNC"
    echo "   - 鎴栬€呯洿鎺ュ湪 Web 闈㈡澘涓婁紶鐜版湁瀛樻。骞惰涓洪粯璁よ嚜鍔ㄥ姞杞?
    echo ""

    echo -e "${BOLD}5. 鐜╁鍙互杩炴帴锛?{NC}"
    echo "   - 鎵撳紑鏄熼湶璋风墿璇?
    echo '   - 鐐瑰嚮 "鍚堜綔" 鈫?"鍔犲叆灞€鍩熺綉娓告垙"'
    echo "   - 鏈嶅姟鍣ㄤ細鑷姩鏄剧ず锛屾垨鎵嬪姩杈撳叆鏈嶅姟鍣?IP"
    echo -e "   ${YELLOW}鈿狅笍  娉ㄦ剰锛氬彧闇€杈撳叆 IP锛岀鍙?24642 鏄粯璁ょ殑鏃犻渶鎸囧畾${NC}"
    echo ""

    echo -e "${BOLD}甯哥敤鍛戒护锛?{NC}"
    echo -e "   鏌ョ湅鏃ュ織:        ${CYAN}docker logs -f nothing-stardew${NC}"
    echo -e "   閲嶅惎鏈嶅姟鍣?      ${CYAN}$COMPOSE_CMD down && $COMPOSE_CMD up -d${NC}"
    echo -e "   鍋滄鏈嶅姟鍣?      ${CYAN}$COMPOSE_CMD down${NC}"
    echo -e "   妫€鏌ュ仴搴?        ${CYAN}./health-check.sh${NC}"
    echo -e "   澶囦唤瀛樻。:        ${CYAN}./backup.sh${NC}"
    echo ""
    echo -e "${YELLOW}   鈿狅笍  娉ㄦ剰: 淇敼 .env 鍚庡繀椤婚噸鍚墠鑳界敓鏁堬紒${NC}"
    echo ""

    echo -e "${GREEN}${BOLD}馃専 浜彈鎮ㄧ殑鍗虫椂鐫＄湢鏄熼湶璋锋湇鍔″櫒锛?{NC}"
    echo ""

    # 鏅鸿兘妫€娴嬫槸鍚﹂渶瑕?Steam Guard 楠岃瘉鐮?
    echo ""
    print_info "姝ｅ湪妫€娴嬫湇鍔″櫒鐘舵€?.."
    sleep 2

    NEEDS_STEAM_GUARD=false
    RECENT_LOGS=$(docker logs --tail 50 nothing-stardew 2>&1 || true)
    if echo "$RECENT_LOGS" | grep -qi "steam guard\|two-factor\|two factor\|auth code\|verification code\|Enter the current code"; then
        NEEDS_STEAM_GUARD=true
    fi

    if [ "$NEEDS_STEAM_GUARD" = "true" ]; then
        echo ""
        print_warning "鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹?
        print_warning "  妫€娴嬪埌 Steam 闇€瑕侀獙璇佺爜锛?
        print_warning "鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹佲攣鈹?
        echo ""
        print_info "鎮ㄩ渶瑕侀檮鍔犲埌瀹瑰櫒鏉ヨ緭鍏?Steam Guard 楠岃瘉鐮併€?
        print_info "璇锋寜浠ヤ笅姝ラ鎿嶄綔锛?
        echo ""
        echo -e "  ${CYAN}1.${NC} 杩愯: ${CYAN}docker attach nothing-stardew${NC}"
        echo -e "  ${CYAN}2.${NC} 杈撳叆閭欢/鎵嬫満搴旂敤涓敹鍒扮殑楠岃瘉鐮侊紝鎸夊洖杞?
        echo -e "  ${CYAN}3.${NC} 绛夊緟 3-5 绉掔‘璁ゆ父鎴忓紑濮嬩笅杞?
        echo -e "  ${CYAN}4.${NC} 鎸?${YELLOW}Ctrl+P Ctrl+Q${NC} 鍒嗙瀹瑰櫒锛?{RED}涓嶈鎸?Ctrl+C锛?{NC}锛?
        echo ""
    else
        echo ""
        ask_question "璇烽€夋嫨涓嬩竴姝ユ搷浣滐細"
        echo -e "  ${CYAN}1${NC} - 鏌ョ湅瀹炴椂鏃ュ織: ${CYAN}docker logs -f nothing-stardew${NC}"
        echo -e "  ${CYAN}2${NC} - 闄勫姞鍒板鍣紙鍙氦浜掕緭鍏ラ獙璇佺爜锛? ${CYAN}docker attach nothing-stardew${NC}"
        echo ""
        print_info "鎮ㄥ彲浠ョ洿鎺ュ鍒朵笂鏂瑰懡浠ゅ湪缁堢鎵ц銆?
    fi
}

# =============================================================================
# 涓绘祦绋?
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

# 杩愯涓诲嚱鏁?
main
