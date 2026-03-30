#!/bin/bash
# Init Container Script - Run permission fixes before main container starts
#
# This script runs as root in a lightweight init container to:
# 1. Fix data directory ownership (UID 1000 = steam user)
# 2. Create required directories
# 3. Set up libcurl compatibility symlink

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[Init]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[Init]${NC} $1"; }

log_info "================================================"
log_info "  Nothing Stardew Server - Init Container"
log_info "================================================"

log_info "Creating data directories..."
DIRS=(
    "/home/steam/.config/StardewValley"
    "/home/steam/.config/StardewValley/ErrorLogs"
    "/home/steam/stardewvalley"
    "/home/steam/Steam"
    "/home/steam/web-panel/data"
    "/home/steam/.local/share/nothing-stardew"
    "/home/steam/.local/share/nothing-stardew/logs"
    "/home/steam/.local/share/nothing-stardew/backups"
)

for dir in "${DIRS[@]}"; do
    mkdir -p "$dir"
done
log_info "[OK] Directories created"

log_info "Fixing file ownership..."
FIXED_COUNT=0
for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        WRONG_OWNER=$(find "$dir" ! -uid 1000 2>/dev/null | wc -l)
        if [ "$WRONG_OWNER" -gt 0 ]; then
            log_warn "Fixing $WRONG_OWNER item(s) in $dir"
            chown -R 1000:1000 "$dir" 2>/dev/null || true
            FIXED_COUNT=$((FIXED_COUNT + WRONG_OWNER))
        fi
    fi
done

if [ "$FIXED_COUNT" -gt 0 ]; then
    log_info "[OK] Fixed permissions for $FIXED_COUNT item(s)"
else
    log_info "[OK] Permissions already correct"
fi

log_info "Setting up libcurl compatibility..."
if [ ! -f "/usr/lib/x86_64-linux-gnu/libcurl.so.4" ]; then
    rm -f /usr/lib/x86_64-linux-gnu/libcurl.so.4 2>/dev/null || true
    ln -sf /usr/lib/i386-linux-gnu/libcurl.so.4 /usr/lib/x86_64-linux-gnu/libcurl.so.4
    log_info "[OK] libcurl symlink created"
else
    log_info "[OK] libcurl already configured"
fi

if [ "$USE_GPU" = "true" ]; then
    log_info "GPU mode enabled, preparing Xorg directories..."
    mkdir -p /tmp/.X11-unix
    chmod 1777 /tmp/.X11-unix
    mkdir -p /home/steam/.local/share/xorg
    chown 1000:1000 /home/steam/.local/share/xorg 2>/dev/null || true
    log_info "[OK] GPU directories prepared"
fi

log_info "================================================"
log_info "  Init complete. Main container can start."
log_info "================================================"
