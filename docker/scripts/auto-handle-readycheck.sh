#!/bin/bash
# Auto-Handle ReadyCheckDialog - Background Script
#
# Handles ReadyCheckDialog confirmations for special events such as earthquakes.
# Other menus are expected to be handled by AutoHideHost.

SMAPI_LOG="/home/steam/.config/StardewValley/ErrorLogs/SMAPI-latest.txt"
CHECK_INTERVAL=3
LOCK_FILE="/tmp/stardew-key-lock"
LOCK_TIMEOUT=10

log() {
    echo -e "\033[0;35m[Auto-Handle-ReadyCheck]\033[0m $1"
}

send_key_locked() {
    local key="$1"
    (
        if flock -w "$LOCK_TIMEOUT" 200; then
            xdotool key "$key" 2>/dev/null
        else
            log "[WARN] Could not acquire keyboard lock"
            return 1
        fi
    ) 200>"$LOCK_FILE"
}

log "Starting ReadyCheckDialog auto-handler..."
log "Only ReadyCheckDialog is handled here. Other menus should be handled by AutoHideHost."

export DISPLAY=:99
LAST_HANDLE_TIME=0

while true; do
    if [ -f "$SMAPI_LOG" ]; then
        CURRENT_TIME=$(date +%s)

        if [ $((CURRENT_TIME - LAST_HANDLE_TIME)) -lt 10 ]; then
            sleep $CHECK_INTERVAL
            continue
        fi

        RECENT_LOG=$(tail -30 "$SMAPI_LOG" 2>/dev/null)

        if echo "$RECENT_LOG" | grep -q "ReadyCheckDialog"; then
            log "[WARN] ReadyCheckDialog detected"
            sleep 2

            if command -v xdotool >/dev/null 2>&1; then
                log "Sending Enter to confirm the dialog..."
                send_key_locked Return
                sleep 0.5
                send_key_locked Return
                sleep 0.5
                send_key_locked Return

                log "[OK] Confirmation keys sent"
                LAST_HANDLE_TIME=$(date +%s)
                sleep 10
            else
                log "[ERROR] xdotool is not installed, cannot auto-confirm the dialog"
            fi
        fi
    fi

    sleep $CHECK_INTERVAL
done
