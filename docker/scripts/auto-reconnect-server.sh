#!/bin/bash
# Auto-Reconnect Server - Background Script
#
# Monitors SMAPI logs for ServerOfflineMode and attempts to re-enable the LAN server.

SMAPI_LOG="/home/steam/.config/StardewValley/ErrorLogs/SMAPI-latest.txt"
CHECK_INTERVAL=60
OFFLINE_MARKER="[ServerOfflineMode]"
LOCK_FILE="/tmp/stardew-key-lock"
LOCK_TIMEOUT=10

log() {
    echo -e "\033[0;36m[Auto-Reconnect]\033[0m $1"
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

log "Starting server auto-reconnect monitor..."
log "Check interval: ${CHECK_INTERVAL}s"
log "Waiting for initial game startup..."
sleep 20

OFFLINE_DETECTED=false
LAST_OFFLINE_COUNT=0

while true; do
    if [ -f "$SMAPI_LOG" ]; then
        CURRENT_OFFLINE_COUNT=$(grep -c "$OFFLINE_MARKER" "$SMAPI_LOG" 2>/dev/null || echo "0")

        if [ "$CURRENT_OFFLINE_COUNT" -gt "$LAST_OFFLINE_COUNT" ]; then
            log "[WARN] Detected ServerOfflineMode ($LAST_OFFLINE_COUNT -> $CURRENT_OFFLINE_COUNT)"
            sleep 5

            VERIFY_COUNT=$(grep -c "$OFFLINE_MARKER" "$SMAPI_LOG" 2>/dev/null || echo "0")
            if [ "$VERIFY_COUNT" -gt "$LAST_OFFLINE_COUNT" ]; then
                log "[OK] Confirmed ServerOfflineMode, attempting reconnect..."
                export DISPLAY=:99

                if command -v xdotool >/dev/null 2>&1; then
                    log "  Method 1: press F9 to toggle AlwaysOnServer..."

                    for i in 1 2 3; do
                        send_key_locked Escape
                        sleep 0.2
                    done
                    sleep 1

                    send_key_locked F9
                    sleep 2
                    send_key_locked F9

                    log "  [OK] F9 keypresses sent"
                    sleep 10

                    LAST_OFFLINE_COUNT=$VERIFY_COUNT
                    OFFLINE_DETECTED=true
                    log "[OK] Reconnect attempt sent, check whether connectivity has recovered"
                else
                    log "[ERROR] xdotool is not installed, cannot auto-reconnect"
                    log "Use VNC and press F9 manually if needed"
                fi
            else
                log "[INFO] False alarm, continuing to monitor..."
            fi
        fi

        NEW_OFFLINE_COUNT=$(grep -c "$OFFLINE_MARKER" "$SMAPI_LOG" 2>/dev/null || echo "0")
        if [ "$NEW_OFFLINE_COUNT" -lt "$LAST_OFFLINE_COUNT" ]; then
            log "[INFO] Log rotation or truncation detected, resetting offline counter"
            LAST_OFFLINE_COUNT=$NEW_OFFLINE_COUNT
        fi
    fi

    sleep "$CHECK_INTERVAL"
done
