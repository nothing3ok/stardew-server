#!/bin/bash
# Nothing Stardew Server Entrypoint Script - v1.0.77

# DO NOT use set -e - we need manual error handling

# Color codes for pretty logging
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PANEL_ENV_FILE=${ENV_FILE:-/home/steam/web-panel/data/runtime.env}

if [ ! -f "$PANEL_ENV_FILE" ] && [ -f "/home/steam/.env" ]; then
    PANEL_ENV_FILE="/home/steam/.env"
fi

load_panel_env_overrides() {
    local env_file=${1:-$PANEL_ENV_FILE}

    [ -f "$env_file" ] || return 0

    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
            ''|\#*) continue ;;
        esac

        local key=${line%%=*}
        local value=${line#*=}

        case "$key" in
            ''|*[!A-Za-z0-9_]*)
                continue
                ;;
        esac

        export "$key=$value"
    done < "$env_file"
}

load_panel_env_overrides

# Resolution and performance environment variables with defaults
DEFAULT_RESOLUTION_WIDTH=1280
DEFAULT_RESOLUTION_HEIGHT=720
DEFAULT_REFRESH_RATE=60
LOW_PERF_DEFAULT_WIDTH=800
LOW_PERF_DEFAULT_HEIGHT=600
LOW_PERF_DEFAULT_FPS=30
LOW_PERF_DEFAULT_COLOR_DEPTH=16

LOW_PERF_MODE=${LOW_PERF_MODE:-false}
TARGET_FPS_RAW=${TARGET_FPS:-}
RESOLUTION_WIDTH=${RESOLUTION_WIDTH:-$DEFAULT_RESOLUTION_WIDTH}
RESOLUTION_HEIGHT=${RESOLUTION_HEIGHT:-$DEFAULT_RESOLUTION_HEIGHT}
REFRESH_RATE=${REFRESH_RATE:-${TARGET_FPS_RAW:-$DEFAULT_REFRESH_RATE}}
TARGET_FPS=${TARGET_FPS_RAW:-$REFRESH_RATE}
XVFB_COLOR_DEPTH=24
XVFB_FB_DIR=""
XVFB_FB_ARGS=()

# Logging functions
log_info() {
    echo -e "${GREEN}[Nothing-Stardew]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[Nothing-Stardew]${NC} $1"
}

log_error() {
    echo -e "${RED}[Nothing-Stardew]${NC} $1"
}

log_step() {
    echo -e "${BLUE}${1}${NC}"
}

log_steam() {
    echo -e "${CYAN}$1${NC}"
}

configure_audio_driver() {
    if [ -n "${SDL_AUDIODRIVER:-}" ]; then
        :
    else
        export SDL_AUDIODRIVER=dummy
        log_info "No explicit audio driver configured; defaulting SDL_AUDIODRIVER=dummy"
    fi

    if [ -z "${ALSOFT_DRIVERS:-}" ]; then
        export ALSOFT_DRIVERS=null
        log_info "No explicit OpenAL driver configured; defaulting ALSOFT_DRIVERS=null"
    fi
}

configure_performance_mode() {
    if [ "$LOW_PERF_MODE" != "true" ]; then
        return 0
    fi

    RESOLUTION_WIDTH=${LOW_PERF_RESOLUTION_WIDTH:-$LOW_PERF_DEFAULT_WIDTH}
    RESOLUTION_HEIGHT=${LOW_PERF_RESOLUTION_HEIGHT:-$LOW_PERF_DEFAULT_HEIGHT}

    if [ -z "$TARGET_FPS_RAW" ]; then
        TARGET_FPS=$LOW_PERF_DEFAULT_FPS
    fi
    REFRESH_RATE=${LOW_PERF_REFRESH_RATE:-$TARGET_FPS}
    XVFB_COLOR_DEPTH=${LOW_PERF_COLOR_DEPTH:-$LOW_PERF_DEFAULT_COLOR_DEPTH}

    export SDL_VIDEODRIVER=${SDL_VIDEODRIVER:-x11}
    export SDL_AUDIODRIVER=${SDL_AUDIODRIVER:-dummy}
    export MONO_GC_PARAMS=${MONO_GC_PARAMS:-nursery-size=8m}
    export DOTNET_GCHeapHardLimit=${DOTNET_GCHeapHardLimit:-0x30000000}

    if [ "${USE_GPU:-false}" != "true" ]; then
        export LIBGL_ALWAYS_SOFTWARE=${LIBGL_ALWAYS_SOFTWARE:-1}
    fi

    XVFB_FB_DIR=${XVFB_FB_DIR:-/dev/shm/xvfb}
    if mkdir -p "$XVFB_FB_DIR" 2>/dev/null; then
        XVFB_FB_ARGS=(-fbdir "$XVFB_FB_DIR")
    else
        XVFB_FB_DIR=""
        XVFB_FB_ARGS=()
    fi

    log_info "Low performance mode enabled"
    log_info "  Render target: ${RESOLUTION_WIDTH}x${RESOLUTION_HEIGHT} @ ${REFRESH_RATE}fps"
    log_info "  Xvfb color depth: ${XVFB_COLOR_DEPTH}bit"
    log_info "  SDL_VIDEODRIVER=${SDL_VIDEODRIVER}"
    log_info "  SDL_AUDIODRIVER=${SDL_AUDIODRIVER}"
    log_info "  MONO_GC_PARAMS=${MONO_GC_PARAMS}"
    log_info "  DOTNET_GCHeapHardLimit=${DOTNET_GCHeapHardLimit}"
    if [ -n "${LIBGL_ALWAYS_SOFTWARE:-}" ]; then
        log_info "  LIBGL_ALWAYS_SOFTWARE=${LIBGL_ALWAYS_SOFTWARE}"
    fi
    if [ -n "$XVFB_FB_DIR" ]; then
        log_info "  Xvfb framebuffer directory: $XVFB_FB_DIR"
    fi
}

apply_startup_preferences_tuning() {
    local config_file=$1

    [ -f "$config_file" ] || return 0

    if [ "$LOW_PERF_MODE" != "true" ]; then
        return 0
    fi

    perl -0pi -e "s#<fullscreenResolutionX>.*?</fullscreenResolutionX>#<fullscreenResolutionX>${RESOLUTION_WIDTH}</fullscreenResolutionX>#s;
        s#<fullscreenResolutionY>.*?</fullscreenResolutionY>#<fullscreenResolutionY>${RESOLUTION_HEIGHT}</fullscreenResolutionY>#s;
        s#<preferredResolutionX>.*?</preferredResolutionX>#<preferredResolutionX>${RESOLUTION_WIDTH}</preferredResolutionX>#s;
        s#<preferredResolutionY>.*?</preferredResolutionY>#<preferredResolutionY>${RESOLUTION_HEIGHT}</preferredResolutionY>#s;
        s#<vsyncEnabled>.*?</vsyncEnabled>#<vsyncEnabled>true</vsyncEnabled>#s;
        s#<startMuted>.*?</startMuted>#<startMuted>true</startMuted>#s;
        s#<musicVolumeLevel>.*?</musicVolumeLevel>#<musicVolumeLevel>0</musicVolumeLevel>#s;
        s#<soundVolumeLevel>.*?</soundVolumeLevel>#<soundVolumeLevel>0</soundVolumeLevel>#s;" "$config_file"
}

# Function to download game via steamcmd
download_game_via_steam() {
    log_info "========================================="
    log_info "  Starting Steam download process"
    log_info "========================================="
    log_info ""
    log_info "If Steam Guard is required, you will see a prompt."
    log_info ""
    log_info "To input Steam Guard code:"
    log_info "  1. You should already have run: docker attach nothing-stardew"
    log_info "  2. Enter the code when prompted below"
    log_info "  3. Press ENTER"
    log_info ""
    log_info "After successful authentication, game will download (~708MB)"
    log_info "========================================="
    log_info ""

    # Support STEAM_GUARD_CODE environment variable for easier auth
    STEAM_GUARD_ARGS=""
    if [ -n "$STEAM_GUARD_CODE" ]; then
        log_info "Using Steam Guard code from environment variable"
        STEAM_GUARD_ARGS="+set_steam_guard_code $STEAM_GUARD_CODE"
    fi

    # Run steamcmd WITHOUT pipe - this preserves stdin!
    /home/steam/steamcmd/steamcmd.sh \
        +force_install_dir /home/steam/stardewvalley \
        $STEAM_GUARD_ARGS \
        +login "$STEAM_USERNAME" "$STEAM_PASSWORD" \
        +app_update 413150 validate \
        +quit

    DOWNLOAD_EXIT_CODE=$?

    # Check result
    if [ -f "/home/steam/stardewvalley/StardewValley" ]; then
        log_info "[OK] Game downloaded successfully!"
        return 0
    else
        log_error "[ERROR] Game download failed (exit code: $DOWNLOAD_EXIT_CODE)"
        log_error ""
        return 1
    fi
}

# =============================================
# GPU-related helper function
# =============================================
start_gpu_xorg() {
    local context=${1:-"unknown"}
    if [ "$USE_GPU" != "true" ]; then
        log_warn "USE_GPU != true, skipping GPU startup (context: $context)"
        return 3
    fi

    log_info "USE_GPU=true -> Attempting to start Xorg :99 for GPU rendering (context: $context)"
    rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 2>/dev/null || true

    if [ -e /dev/dri/renderD128 ] || ls /dev/dri 2>/dev/null | grep -q .; then
        log_info "Detected /dev/dri, starting Xorg :99 (context: $context)"

        # Ensure X socket directory exists with correct permissions
        mkdir -p /tmp/.X11-unix
        chmod 1777 /tmp/.X11-unix

        # Ensure Xorg log directory exists
        mkdir -p /home/steam/.local/share/xorg
        if [ "$(id -u)" = "0" ]; then
            chown root:root /home/steam/.local/share/xorg 2>/dev/null || true
        fi

        # Start Xorg in background
        Xorg -noreset +extension GLX +extension RANDR :99 -logfile /home/steam/.local/share/xorg/Xorg.0.log &
        sleep 2

        # Set resolution via set-resolution.sh
        DISPLAY=:99 /home/steam/scripts/set-resolution.sh "${RESOLUTION_WIDTH}" "${RESOLUTION_HEIGHT}" "${REFRESH_RATE}" || {
            log_warn "Failed to set resolution (context: $context), continuing with default"
        }
        sleep 1

        if pgrep -x Xorg >/dev/null 2>&1; then
            export DISPLAY=${DISPLAY:-:99}
            log_info "[OK] Xorg started on :99 (context: $context)"
            if command -v glxinfo >/dev/null 2>&1; then
                log_info "OpenGL renderer:"
                glxinfo | grep -i "OpenGL renderer" | head -n 1 || true
            fi
            return 0
        else
            log_warn "Xorg failed to start (context: $context)"
            return 2
        fi
    else
        log_warn "/dev/dri not detected, skipping Xorg startup (context: $context)"
        return 1
    fi
}

# =============================================
# Phase 1: Root Initialization
#
# Permission fixes are handled by the init container (init-container.sh).
# This phase only handles GPU Xorg startup (requires root) and user switch.
# =============================================

configure_audio_driver
configure_performance_mode

if [ "$(id -u)" = "0" ]; then
    log_step "================================================"
    log_step "  Phase 1: Root Initialization"
    log_step "================================================"

    # Fix libcurl compatibility for SteamCMD (idempotent, fast)
    if [ ! -e "/usr/lib/x86_64-linux-gnu/libcurl.so.4" ]; then
        ln -sf /usr/lib/i386-linux-gnu/libcurl.so.4 /usr/lib/x86_64-linux-gnu/libcurl.so.4
        log_info "[OK] libcurl symlink created"
    fi

    # Try to start Xorg in root phase if USE_GPU=true
    # Xorg requires root privileges to access /dev/dri
    if [ "$USE_GPU" = "true" ]; then
        start_gpu_xorg "root" || {
            log_warn "GPU startup in root phase unsuccessful, will fallback to Xvfb"
        }
    fi

    mkdir -p /home/steam/.local/share/nothing-stardew \
             /home/steam/.local/share/nothing-stardew/logs \
             /home/steam/.local/share/nothing-stardew/backups \
             /home/steam/web-panel/data
    chown -R 1000:1000 /home/steam/.local/share/nothing-stardew /home/steam/web-panel/data 2>/dev/null || true

    log_info "Switching to steam user..."

    # Re-execute this script as steam user
    exec runuser -u steam -- env DISPLAY="$DISPLAY" "$0" "$@"
fi

# =============================================
# Phase 2: Steam User Operations
# =============================================

log_step "================================================"
log_step "  Nothing Stardew Server v1.0.77 Starting..."
log_step "================================================"

# Verify we're running as steam user
if [ "$(id -u)" != "1000" ]; then
    log_error "ERROR: Script must run as steam user (UID 1000)"
    exit 1
fi

# Step 1: Validate Steam credentials (supports Docker Secrets)
log_step "Step 1: Validating configuration..."

# Docker Secrets support: read from /run/secrets/ if env vars are empty
if [ -z "$STEAM_USERNAME" ] && [ -f "/run/secrets/steam_username" ]; then
    STEAM_USERNAME=$(cat /run/secrets/steam_username | tr -d '\n')
    log_info "Steam username loaded from Docker Secret"
fi
if [ -z "$STEAM_PASSWORD" ] && [ -f "/run/secrets/steam_password" ]; then
    STEAM_PASSWORD=$(cat /run/secrets/steam_password | tr -d '\n')
    log_info "Steam password loaded from Docker Secret"
fi

if [ -z "$STEAM_USERNAME" ] || [ -z "$STEAM_PASSWORD" ]; then
    log_error "STEAM_USERNAME or STEAM_PASSWORD not set!"
    log_error "Set via .env file or Docker Secrets."
    exit 1
fi

log_info "Steam username: $STEAM_USERNAME"

# Step 2: Download game if needed
if [ ! -f "/home/steam/stardewvalley/StardewValley" ]; then
    log_step "Step 2: Downloading Stardew Valley..."
    log_warn "Game files not found. Downloading from Steam..."
    log_warn "This will take 5-10 minutes depending on your connection."
    log_warn ""

    # Clean up any existing Steam cache
    log_info "Cleaning Steam cache..."
    rm -rf /home/steam/Steam/config/* 2>/dev/null || true
    rm -rf /home/steam/Steam/logs/* 2>/dev/null || true
    rm -rf /tmp/steam* 2>/dev/null || true

    # Download game (handles Steam Guard automatically)
    if ! download_game_via_steam; then
        log_error "Failed to download game. Container will exit."
        exit 1
    fi
else
    log_step "Step 2: Game files found, skipping download"
    log_info "[OK] Stardew Valley already downloaded"
fi

# Step 3: Install SMAPI
log_step "Step 3: Installing SMAPI mod loader..."

if [ ! -f "/home/steam/stardewvalley/StardewModdingAPI" ]; then
    log_info "Installing SMAPI..."
    cd /home/steam
    echo "1" | dotnet smapi/SMAPI*/internal/linux/SMAPI.Installer.dll --install --game-path /home/steam/stardewvalley

    if [ $? -ne 0 ]; then
        log_error "Failed to install SMAPI!"
        exit 1
    fi

    log_info "[OK] SMAPI installed successfully!"
else
    log_info "[OK] SMAPI already installed"
fi

# Step 4: Install mods
log_step "Step 4: Installing mods..."

mkdir -p /home/steam/stardewvalley/Mods

if [ -d "/home/steam/preinstalled-mods" ]; then
    if [ -d "/home/steam/stardewvalley/Mods/AutoHideHost" ]; then
        log_info "[OK] Mods already installed"
    else
        log_info "Installing mods..."
        cp -r /home/steam/preinstalled-mods/* /home/steam/stardewvalley/Mods/
        log_info "[OK] Mods installed successfully!"
    fi

    log_info "Installed mods:"
    ls -1 /home/steam/stardewvalley/Mods/ | while read mod; do
        log_info "  [OK] $mod"
    done
fi

# Step 4.5: Install user-provided mods from custom-mods volume
CUSTOM_MODS_DIR="/home/steam/custom-mods"
if [ -d "$CUSTOM_MODS_DIR" ] && [ "$(ls -A "$CUSTOM_MODS_DIR" 2>/dev/null)" ]; then
    log_step "Step 4.5: Installing custom mods..."
    log_info "Found custom mods in $CUSTOM_MODS_DIR"

    for mod_entry in "$CUSTOM_MODS_DIR"/*; do
        mod_name=$(basename "$mod_entry")

        # Skip hidden files
        [[ "$mod_name" == .* ]] && continue

        if [ -d "$mod_entry" ]; then
            # It's a mod directory - copy to Mods/
            log_info "  Installing mod: $mod_name"
            cp -r "$mod_entry" "/home/steam/stardewvalley/Mods/$mod_name"
        elif [[ "$mod_entry" == *.zip ]]; then
            # It's a zip file - extract to Mods/
            log_info "  Extracting mod: $mod_name"
            unzip -q -o "$mod_entry" -d "/home/steam/stardewvalley/Mods/" 2>/dev/null || {
                log_warn "  [WARN] Failed to extract: $mod_name"
            }
        fi
    done
    log_info "[OK] Custom mods installed"
fi

# Step 5: Setup virtual display
log_step "Step 5: Starting virtual display..."

# Check if Xorg is already running from root phase
START_XVFB_FALLBACK=false

if pgrep -x Xorg >/dev/null 2>&1; then
    export DISPLAY=${DISPLAY:-:99}
    log_info "Detected Xorg process, using DISPLAY=${DISPLAY}"
    if command -v glxinfo >/dev/null 2>&1; then
        log_info "OpenGL renderer:"
        glxinfo | grep -i "OpenGL renderer" | head -n 1 || true
    fi
else
    # Fallback to Xvfb if GPU not enabled or failed
    if [ "$USE_GPU" = "true" ]; then
        log_warn "Xorg not running in steam phase, falling back to Xvfb"
    fi
    START_XVFB_FALLBACK=true
fi

# Start Xvfb as fallback
if [ "$START_XVFB_FALLBACK" = "true" ]; then
    log_info "Starting Xvfb (software rendering fallback)..."
    rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 2>/dev/null || true
    Xvfb :99 -screen 0 "${RESOLUTION_WIDTH}x${RESOLUTION_HEIGHT}x${XVFB_COLOR_DEPTH}" -ac +extension GLX +render -noreset "${XVFB_FB_ARGS[@]}" &
    export DISPLAY=${DISPLAY:-:99}
    sleep 3
    log_info "[OK] Virtual display started on ${DISPLAY} (${RESOLUTION_WIDTH}x${RESOLUTION_HEIGHT}x${XVFB_COLOR_DEPTH})"
fi

# Step 6: Start VNC server (optional)
if [ "$ENABLE_VNC" = "true" ]; then
    log_step "Step 6: Starting VNC server..."

    VNC_PASSWORD=${VNC_PASSWORD:-"stardew1"}

    if [ ${#VNC_PASSWORD} -gt 8 ]; then
        log_warn "VNC password > 8 chars, truncating to: ${VNC_PASSWORD:0:8}"
        VNC_PASSWORD="${VNC_PASSWORD:0:8}"
    fi

    # Wait for X server to be fully ready
    sleep 2

    # Start x11vnc pointing to current DISPLAY
    log_info "Starting x11vnc on display ${DISPLAY} (port 5900)..."
    x11vnc -display "${DISPLAY}" -forever -shared -passwd "$VNC_PASSWORD" -rfbport 5900 -noxdamage -bg 2>&1 | grep -v "^$"

    # Wait for x11vnc to start
    sleep 2

    # Verify VNC is running
    if pgrep -x "x11vnc" >/dev/null; then
        log_info "[OK] VNC server started successfully on port 5900"
        log_info "  Password: $VNC_PASSWORD"
        log_info "  Connect to: your-server-ip:5900"

        # Start VNC monitor to keep it alive
        if [ -f "/home/steam/scripts/vnc-monitor.sh" ]; then
            log_info "Starting VNC health monitor..."
            /home/steam/scripts/vnc-monitor.sh &
            log_info "[OK] VNC monitor started (30s check interval)"
        fi
    else
        log_error "[OK] VNC server failed to start"
        log_error "Check logs above for errors"
    fi
else
    log_step "Step 6: VNC disabled (set ENABLE_VNC=true to enable)"
fi

# Step 7: Setup optimized game config for VNC display
log_step "Step 7: Configuring game display settings..."

CONFIG_DIR="/home/steam/.config/StardewValley"
CONFIG_FILE="$CONFIG_DIR/startup_preferences"
TEMPLATE="/home/steam/startup_preferences.template"

# Create config directory if not exists
mkdir -p "$CONFIG_DIR"

# Copy optimized config template if startup_preferences doesn't exist yet
if [ ! -f "$CONFIG_FILE" ]; then
    if [ -f "$TEMPLATE" ]; then
        cp "$TEMPLATE" "$CONFIG_FILE"
        log_info "[OK] Applied optimized display config (fullscreen mode for VNC)"
    else
        log_warn "[WARN] Template not found, game will use default settings"
    fi
else
    log_info "[OK] Game config already exists, keeping user settings"
fi

apply_startup_preferences_tuning "$CONFIG_FILE"
if [ "$LOW_PERF_MODE" = "true" ]; then
    log_info "[OK] Applied low performance startup preferences"
fi

# Step 7.5: Select save if specified
if [ -n "$SAVE_NAME" ]; then
    log_step "Step 7.5: Selecting save file..."
    /home/steam/scripts/save-selector.sh
fi

# Step 8: Start log monitoring (optional)
if [ "$ENABLE_LOG_MONITOR" = "true" ]; then
    log_step "Step 8: Starting log monitoring..."

    if [ -f "/home/steam/scripts/log-monitor.sh" ]; then
        /home/steam/scripts/log-monitor.sh &
        log_info "[OK] Log monitoring started"
    fi
else
    log_step "Step 8: Log monitoring disabled"
fi

# Step 9: Start game server
log_step "Step 9: Starting game server..."
log_info "================================================"
log_info "  Server is starting!"
log_info "================================================"
log_info ""
log_info "Save setup options:"
log_info "  1. Web panel: http://localhost:18642 (set admin password on first visit)"
log_info "  2. Upload an existing save in the panel and set it as the default auto-load save"
log_info "  3. Optional: use VNC only if you want to create a new save manually in-game"
log_info ""
log_info "Players connect via:"
log_info "  1. Open Stardew Valley ->CO-OP ->Join LAN Game"
log_info "  2. Server will appear automatically, or enter server IP directly"
log_info "  3. No port number needed (default: 24642/UDP)"
log_info "================================================"
log_info ""

cd /home/steam/stardewvalley

# Start unified event handler in background
log_info "Starting unified event handler..."
/home/steam/scripts/event-handler.sh &

# Start auto-backup if enabled
if [ "$ENABLE_AUTO_BACKUP" = "true" ]; then
    log_info "Starting auto-backup service..."
    /home/steam/scripts/auto-backup.sh &
fi

# Start status reporter (Prometheus metrics + JSON status)
log_info "Starting status reporter (metrics port: ${METRICS_PORT:-9090})..."
/home/steam/scripts/status-reporter.sh &

# Start web panel
log_info "Starting web management panel (port: 18642)..."
cd /home/steam/web-panel
node server.js &
WEB_PANEL_PID=$!
log_info "[OK] Web panel started (PID: $WEB_PANEL_PID)"
log_info "  Access at: http://localhost:18642"
cd /home/steam/stardewvalley

# Start player access control if configured
if [ -f "/home/steam/.config/StardewValley/player-access.conf" ]; then
    log_info "Starting player access control..."
    /home/steam/scripts/player-access.sh &
fi

# Start crash monitor if enabled
if [ "$ENABLE_CRASH_RESTART" = "true" ]; then
    log_info "Starting game with crash auto-restart..."

    # Use crash-monitor.sh which wraps game in restart loop
    exec /home/steam/scripts/crash-monitor.sh
else
    # Run game with exec (traditional, container exits on crash)
    exec ./StardewModdingAPI --server
fi
