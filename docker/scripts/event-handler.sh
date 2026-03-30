#!/bin/bash
# Unified event handler for SMAPI log events.
#
# Replaces separate polling scripts with a single tail -F processor and handles:
#   - Passout (2AM): Escape + Enter confirmations
#   - ReadyCheckDialog: Enter confirmations
#   - ServerOfflineMode: F9 toggle to re-enable server
#   - Save loaded: F9 toggle to enable AlwaysOnServer auto mode

SMAPI_LOG="/home/steam/.config/StardewValley/ErrorLogs/SMAPI-latest.txt"
LOCK_FILE="/tmp/stardew-key-lock"
LOCK_TIMEOUT=10

# Cooldown tracking (seconds since epoch)
LAST_PASSOUT_TIME=0
LAST_READYCHECK_TIME=0
LAST_OFFLINE_TIME=0

# Cooldown durations (seconds)
PASSOUT_COOLDOWN=30
READYCHECK_COOLDOWN=10
OFFLINE_COOLDOWN=60

# Flag: has AlwaysOnServer been enabled this session?
AOS_ENABLED=false

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_passout()    { echo -e "${YELLOW}[Event-Passout]${NC} $1"; }
log_readycheck() { echo -e "${PURPLE}[Event-ReadyCheck]${NC} $1"; }
log_reconnect()  { echo -e "${CYAN}[Event-Reconnect]${NC} $1"; }
log_enable()     { echo -e "${CYAN}[Event-AutoEnable]${NC} $1"; }
log_info()       { echo -e "${GREEN}[Event-Handler]${NC} $1"; }

export DISPLAY=:99

send_key_locked() {
    local key="$1"

    (
        if flock -w "$LOCK_TIMEOUT" 200; then
            xdotool key "$key" 2>/dev/null
        else
            log_info "Could not acquire key lock for: $key"
            return 1
        fi
    ) 200>"$LOCK_FILE"
}

check_cooldown() {
    local last_time="$1"
    local cooldown="$2"
    local current_time

    current_time=$(date +%s)
    if [ $((current_time - last_time)) -lt "$cooldown" ]; then
        return 1
    fi

    return 0
}

handle_passout() {
    if ! check_cooldown "$LAST_PASSOUT_TIME" "$PASSOUT_COOLDOWN"; then
        return
    fi

    log_passout "Detected passout event (2AM)."
    LAST_PASSOUT_TIME=$(date +%s)

    if ! command -v xdotool >/dev/null 2>&1; then
        log_passout "xdotool is not installed."
        return
    fi

    sleep 3

    log_passout "Step 1: Close open menus."
    send_key_locked Escape
    sleep 0.5

    log_passout "Step 2: Confirm dialog prompts."
    for i in 1 2 3 4 5; do
        send_key_locked Return
        sleep 1
    done

    log_passout "Passout confirmation sequence sent."

    sleep 5
    if tail -20 "$SMAPI_LOG" 2>/dev/null | grep -qiE "Saving|woke up|Day [0-9]"; then
        log_passout "New day activity detected after passout handling."
    fi
}

handle_readycheck() {
    if ! check_cooldown "$LAST_READYCHECK_TIME" "$READYCHECK_COOLDOWN"; then
        return
    fi

    log_readycheck "Detected ReadyCheckDialog event."
    LAST_READYCHECK_TIME=$(date +%s)

    if ! command -v xdotool >/dev/null 2>&1; then
        log_readycheck "xdotool is not installed."
        return
    fi

    sleep 2

    log_readycheck "Sending Enter to confirm the dialog."
    for i in 1 2 3; do
        send_key_locked Return
        sleep 0.5
    done

    log_readycheck "Confirmation key sent."
}

handle_offline() {
    if ! check_cooldown "$LAST_OFFLINE_TIME" "$OFFLINE_COOLDOWN"; then
        return
    fi

    log_reconnect "Detected ServerOfflineMode."
    LAST_OFFLINE_TIME=$(date +%s)

    if ! command -v xdotool >/dev/null 2>&1; then
        log_reconnect "xdotool is not installed."
        return
    fi

    sleep 5
    log_reconnect "Attempting to re-enable the server."

    for i in 1 2 3; do
        send_key_locked Escape
        sleep 0.2
    done
    sleep 1

    send_key_locked F9
    sleep 2
    send_key_locked F9

    log_reconnect "F9 toggle sequence sent."
}

handle_save_loaded() {
    if [ "$AOS_ENABLED" = "true" ]; then
        return
    fi

    log_enable "Detected save load completion."

    if ! command -v xdotool >/dev/null 2>&1; then
        log_enable "xdotool is not installed."
        return
    fi

    log_enable "Waiting for mods to finish initializing."
    sleep 5

    local on_count off_count
    on_count=$(grep -o "Auto [Mm]ode [Oo]n" "$SMAPI_LOG" 2>/dev/null | wc -l)
    off_count=$(grep -o "Auto mode off" "$SMAPI_LOG" 2>/dev/null | wc -l)

    log_enable "Current state counters: ON=$on_count, OFF=$off_count"

    if [ "$on_count" -gt "$off_count" ]; then
        log_enable "Always On Server already appears to be enabled."
        AOS_ENABLED=true
        return
    fi

    for attempt in 1 2 3; do
        log_enable "Attempt #$attempt: closing menus and sending F9."

        for i in 1 2 3; do
            send_key_locked Escape
            sleep 0.3
        done
        sleep 1

        send_key_locked F9
        log_enable "F9 sent for attempt #$attempt."
        sleep 5

        on_count=$(grep -o "Auto [Mm]ode [Oo]n" "$SMAPI_LOG" 2>/dev/null | wc -l)
        off_count=$(grep -o "Auto mode off" "$SMAPI_LOG" 2>/dev/null | wc -l)

        if [ "$on_count" -gt "$off_count" ]; then
            log_enable "Always On Server enabled successfully."
            AOS_ENABLED=true
            return
        fi

        if [ "$attempt" -lt 3 ]; then
            log_enable "Enable state not detected yet. Retrying in 10 seconds."
            sleep 10
        fi
    done

    log_enable "Could not confirm Always On Server after 3 attempts. Check via VNC if needed."
    AOS_ENABLED=true
}

log_info "========================================"
log_info "  Unified Event Handler Starting..."
log_info "========================================"
log_info ""
log_info "Monitoring events:"
log_info "  - Passout (2AM)"
log_info "  - ReadyCheckDialog"
log_info "  - ServerOfflineMode"
log_info "  - Save Loaded"
log_info ""

log_info "Waiting for game initialization..."
sleep 20

WAIT_COUNT=0
while [ ! -f "$SMAPI_LOG" ]; do
    if [ $((WAIT_COUNT % 12)) -eq 0 ]; then
        log_info "Waiting for SMAPI log file to appear..."
    fi

    sleep 5
    WAIT_COUNT=$((WAIT_COUNT + 1))

    if [ "$WAIT_COUNT" -gt 60 ]; then
        log_info "Still waiting for the log file after 5 minutes. Continuing to wait..."
        WAIT_COUNT=0
    fi
done

log_info "SMAPI log detected: $SMAPI_LOG"

LINE_COUNT=0
HEARTBEAT_INTERVAL=3600

log_info "Starting live log monitor (tail -F)..."

tail -n 0 -F "$SMAPI_LOG" 2>/dev/null | while IFS= read -r line; do
    LINE_COUNT=$((LINE_COUNT + 1))

    if [ $((LINE_COUNT % HEARTBEAT_INTERVAL)) -eq 0 ]; then
        log_info "Event handler still running normally. Processed $LINE_COUNT log lines."
    fi

    case "$line" in
        *"ServerOfflineMode"*|*"[ServerOfflineMode]"*)
            handle_offline
            ;;
        *"SAVE LOADED SUCCESSFULLY"*|*"Context: loaded save"*)
            handle_save_loaded
            ;;
        *"ReadyCheckDialog"*)
            handle_readycheck
            ;;
        *"passed out"*|*"Passed Out"*|*"exhausted"*|*"Exhausted"*|*"collapsed"*|*"Collapsed"*)
            handle_passout
            ;;
    esac
done

log_info "tail -F exited unexpectedly. Restarting in 10 seconds..."
sleep 10
exec "$0" "$@"
