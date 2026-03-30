#!/bin/bash
# =============================================================================
# Nothing Stardew Server - Health Check Script
# =============================================================================
# This script checks whether your Stardew Valley server is running correctly.
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

CONTAINER_NAME="nothing-stardew"
TESTS_PASSED=0
TESTS_FAILED=0
WARNINGS=0

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}==================================================================${NC}"
    echo -e "${CYAN}${BOLD}  Nothing Stardew Server - Health Check${NC}"
    echo -e "${CYAN}${BOLD}==================================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[OK] $1${NC}"
    ((TESTS_PASSED++))
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
    ((TESTS_FAILED++))
}

print_warning() {
    echo -e "${YELLOW}[WARN] $1${NC}"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

print_test() {
    echo ""
    echo -e "${BOLD}$1${NC}"
}

check_docker() {
    print_test "1. Checking Docker..."

    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        return 1
    fi

    if ! docker ps &> /dev/null; then
        print_error "Docker is not running or requires sudo"
        return 1
    fi

    docker_version=$(docker --version | cut -d' ' -f3 | tr -d ',')
    print_success "Docker is running (version $docker_version)"
}

check_container_running() {
    print_test "2. Checking container status..."

    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_error "Container is not running"

        if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
            print_info "Container exists but is stopped. Start it with:"
            echo "  ${CYAN}docker compose up -d${NC}"
        else
            print_info "Container does not exist. Run the setup script first:"
            echo "  ${CYAN}./quick-start.sh${NC}"
        fi
        return 1
    fi

    uptime=$(docker inspect -f '{{.State.StartedAt}}' "$CONTAINER_NAME")
    print_success "Container is running (started: $uptime)"
}

check_container_health() {
    print_test "3. Checking container health..."

    health_status=$(docker inspect -f '{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo "none")

    if [ "$health_status" = "healthy" ]; then
        print_success "Container health status: healthy"
    elif [ "$health_status" = "starting" ]; then
        print_warning "Container health status: starting"
    elif [ "$health_status" = "unhealthy" ]; then
        print_error "Container health status: unhealthy"
        print_info "Check logs: docker logs $CONTAINER_NAME"
        return 1
    else
        print_warning "No health check status available"
    fi
}

check_smapi_running() {
    print_test "4. Checking SMAPI..."

    if docker exec "$CONTAINER_NAME" pgrep -f StardewModdingAPI &> /dev/null; then
        pid=$(docker exec "$CONTAINER_NAME" pgrep -f StardewModdingAPI)
        print_success "SMAPI is running (PID: $pid)"
    else
        print_error "SMAPI is not running"
        print_info "The game may still be downloading or initializing."
        print_info "Check logs: docker logs -f $CONTAINER_NAME"
        return 1
    fi
}

check_mods_loaded() {
    print_test "5. Checking mods..."

    mod_count=$(docker logs --tail 100 "$CONTAINER_NAME" 2>&1 | grep -c "Loaded.*mod" || true)

    if [ "$mod_count" -ge 3 ]; then
        print_success "Mods loaded (detected $mod_count mods)"
        print_info "Core mod hints from recent logs:"
        docker logs --tail 200 "$CONTAINER_NAME" 2>&1 | grep "Loaded.*mod" | grep -i "AlwaysOnServer\|AutoHideHost\|ServerAutoLoad" | while read -r line; do
            echo "  ${CYAN}- ${NC}$(echo "$line" | grep -oP 'Loaded \K.*')"
        done
    elif [ "$mod_count" -gt 0 ]; then
        print_warning "Some mods loaded ($mod_count), but fewer than expected"
    else
        print_warning "No mod load messages detected yet"
    fi
}

check_ports() {
    print_test "6. Checking port bindings..."

    if docker port "$CONTAINER_NAME" 24642/udp &> /dev/null; then
        game_port=$(docker port "$CONTAINER_NAME" 24642/udp)
        print_success "Game port is mapped: $game_port"
    else
        print_error "Game port 24642/udp is not mapped"
        return 1
    fi

    if docker port "$CONTAINER_NAME" 5900/tcp &> /dev/null; then
        vnc_port=$(docker port "$CONTAINER_NAME" 5900/tcp)
        print_success "VNC port is mapped: $vnc_port"
    else
        print_info "VNC port is not mapped"
    fi
}

check_resources() {
    print_test "7. Checking resource usage..."

    stats=$(docker stats "$CONTAINER_NAME" --no-stream --format "{{.CPUPerc}},{{.MemUsage}}")
    cpu=$(echo "$stats" | cut -d',' -f1)
    mem=$(echo "$stats" | cut -d',' -f2)

    echo "  ${CYAN}CPU:${NC} $cpu"
    echo "  ${CYAN}Memory:${NC} $mem"
    print_success "Resource usage collected"
}

check_disk_space() {
    print_test "8. Checking disk space..."

    if [ ! -d "./data" ]; then
        print_warning "Data directory not found"
        return 1
    fi

    data_size=$(du -sh ./data 2>/dev/null | cut -f1 || echo "unknown")
    available_space=$(df -h . | tail -1 | awk '{print $4}')

    echo "  ${CYAN}Data directory size:${NC} $data_size"
    echo "  ${CYAN}Available space:${NC} $available_space"
    print_success "Disk space checked"
}

check_firewall() {
    print_test "9. Firewall reminder..."

    print_info "Make sure port 24642/udp is open:"
    echo ""
    echo "  Ubuntu/Debian:"
    echo "    ${CYAN}sudo ufw allow 24642/udp${NC}"
    echo ""
    echo "  CentOS/RHEL:"
    echo "    ${CYAN}sudo firewall-cmd --add-port=24642/udp --permanent${NC}"
    echo "    ${CYAN}sudo firewall-cmd --reload${NC}"
    echo ""
}

get_server_ip() {
    if command -v curl &> /dev/null; then
        public_ip=$(curl -s ifconfig.me 2>/dev/null || echo "")
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

show_summary() {
    echo ""
    echo -e "${CYAN}${BOLD}==================================================================${NC}"
    echo -e "${BOLD}Summary:${NC}"
    echo -e "${GREEN}  [OK] Passed:    $TESTS_PASSED${NC}"
    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "${RED}  [ERROR] Failed: $TESTS_FAILED${NC}"
    fi
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}  [WARN] Warnings: $WARNINGS${NC}"
    fi
    echo -e "${CYAN}${BOLD}==================================================================${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}${BOLD}Server looks healthy.${NC}"
        echo ""
        echo "Players can usually connect using:"
        echo "  ${CYAN}$(get_server_ip):24642${NC}"
    else
        echo -e "${YELLOW}${BOLD}Some issues were detected.${NC}"
        echo ""
        echo "Suggested next steps:"
        echo "  1. Check logs: ${CYAN}docker logs -f $CONTAINER_NAME${NC}"
        echo "  2. Restart if needed: ${CYAN}docker compose restart${NC}"
    fi
    echo ""
}

main() {
    print_header
    check_docker || true
    check_container_running || true
    check_container_health || true
    check_smapi_running || true
    check_mods_loaded || true
    check_ports || true
    check_resources || true
    check_disk_space || true
    check_firewall || true
    show_summary
}

main
