#!/bin/bash
# Nothing Stardew Server - One-Click Update Script
# 灏忕嫍鏄熻胺鏈嶅姟鍣?- 涓€閿洿鏂拌剼鏈?
#
# Usage: ./update.sh [version]
# 鐢ㄦ硶锛?/update.sh [鐗堟湰鍙穄
#
# Examples:
#   ./update.sh          # Update to latest
#   ./update.sh v1.0.65  # Update to specific version

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

IMAGE="truemanlive/nothing-stardew-server"
CONTAINER="nothing-stardew"
VERSION="${1:-latest}"

log_info() { echo -e "${GREEN}[Update]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[Update]${NC} $1"; }
log_error() { echo -e "${RED}[Update]${NC} $1"; }
log_step() { echo -e "${BLUE}$1${NC}"; }

log_step "========================================"
log_step "  Nothing Stardew Server Updater"
log_step "  灏忕嫍鏄熻胺鏈嶅姟鍣ㄦ洿鏂板伐鍏?
log_step "========================================"
echo ""

# Step 1: Check current version
log_info "Step 1: Checking current version..."
log_info "姝ラ 1: 妫€鏌ュ綋鍓嶇増鏈?.."

CURRENT_IMAGE=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER" 2>/dev/null)
if [ -n "$CURRENT_IMAGE" ]; then
    log_info "  Current / 褰撳墠: $CURRENT_IMAGE"
else
    log_warn "  Container not found / 鏈壘鍒板鍣?
fi
log_info "  Target / 鐩爣: $IMAGE:$VERSION"
echo ""

# Step 2: Backup saves
log_info "Step 2: Backing up saves..."
log_info "姝ラ 2: 澶囦唤瀛樻。..."

BACKUP_DIR="backups"
mkdir -p "$BACKUP_DIR"

if [ -d "data/saves" ]; then
    BACKUP_FILE="$BACKUP_DIR/saves-pre-update-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar -czf "$BACKUP_FILE" data/saves/ 2>/dev/null
    if [ $? -eq 0 ]; then
        log_info "  鉁?Backup saved to / 澶囦唤宸蹭繚瀛樺埌: $BACKUP_FILE"
    else
        log_warn "  鈿?Backup failed, continuing anyway / 澶囦唤澶辫触锛岀户缁洿鏂?
    fi
else
    log_warn "  No saves directory found / 鏈壘鍒板瓨妗ｇ洰褰?
fi
echo ""

# Step 3: Stop server
log_info "Step 3: Stopping server..."
log_info "姝ラ 3: 鍋滄鏈嶅姟鍣?.."

if docker ps -q -f name="$CONTAINER" | grep -q .; then
    docker compose down 2>/dev/null || docker-compose down 2>/dev/null || docker stop "$CONTAINER" 2>/dev/null
    log_info "  鉁?Server stopped / 鏈嶅姟鍣ㄥ凡鍋滄"
else
    log_info "  鉁?Server not running / 鏈嶅姟鍣ㄦ湭杩愯"
fi
echo ""

# Step 4: Pull new image
log_info "Step 4: Pulling new image ($VERSION)..."
log_info "姝ラ 4: 鎷夊彇鏂伴暅鍍?($VERSION)..."

docker pull "$IMAGE:$VERSION"
if [ $? -ne 0 ]; then
    log_error "  鉁?Failed to pull image / 鎷夊彇闀滃儚澶辫触"
    log_error "  Check your network connection / 璇锋鏌ョ綉缁滆繛鎺?
    exit 1
fi
log_info "  鉁?Image pulled successfully / 闀滃儚鎷夊彇鎴愬姛"
echo ""

# Step 5: Update docker-compose.yml if specific version
if [ "$VERSION" != "latest" ]; then
    log_info "Step 5: Updating docker-compose.yml..."
    log_info "姝ラ 5: 鏇存柊 docker-compose.yml..."

    if [ -f "docker-compose.yml" ]; then
        sed -i "s|image: ${IMAGE}:.*|image: ${IMAGE}:${VERSION}|" docker-compose.yml
        log_info "  鉁?Updated image tag to $VERSION"
    fi
else
    log_info "Step 5: Using latest tag, no compose file changes needed"
fi
echo ""

# Step 6: Start server
log_info "Step 6: Starting server..."
log_info "姝ラ 6: 鍚姩鏈嶅姟鍣?.."

docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null
if [ $? -ne 0 ]; then
    log_error "  鉁?Failed to start server / 鍚姩鏈嶅姟鍣ㄥけ璐?
    exit 1
fi
log_info "  鉁?Server started / 鏈嶅姟鍣ㄥ凡鍚姩"

# Verify init container completed
sleep 2
INIT_EXIT=$(docker inspect --format='{{.State.ExitCode}}' nothing-stardew-init 2>/dev/null)
if [ "$INIT_EXIT" != "0" ] && [ -n "$INIT_EXIT" ]; then
    log_warn "  鈿?Init container exit code: $INIT_EXIT"
    log_warn "  Check: docker logs nothing-stardew-init"
fi
echo ""

# Step 7: Show new version
log_info "Step 7: Verifying update..."
log_info "姝ラ 7: 楠岃瘉鏇存柊..."

sleep 3
NEW_IMAGE=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER" 2>/dev/null)
log_info "  Running / 杩愯涓? $NEW_IMAGE"
INIT_STATUS=$(docker inspect --format='{{.State.Status}}' nothing-stardew-init 2>/dev/null)
log_info "  Init container / 鍒濆鍖栧鍣? $INIT_STATUS"
echo ""

# Cleanup old images
log_info "Cleaning up old images..."
log_info "娓呯悊鏃ч暅鍍?.."
docker image prune -f --filter "label=maintainer=truemanlive" 2>/dev/null
echo ""

log_step "========================================"
log_step "  鉁?Update complete! / 鏇存柊瀹屾垚锛?
log_step "========================================"
log_info ""
log_info "Check logs / 鏌ョ湅鏃ュ織: docker logs -f $CONTAINER"
log_info "Backup location / 澶囦唤浣嶇疆: $BACKUP_FILE"
log_info ""
