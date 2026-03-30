#!/bin/bash
# Auto-Handle Passout (2AM) - Background Script
#
# Detects pass-out events and confirms dialogs so the game can continue.

SMAPI_LOG="/home/steam/.config/StardewValley/ErrorLogs/SMAPI-latest.txt"
CHECK_INTERVAL=5
LOCK_FILE="/tmp/stardew-key-lock"
LOCK_TIMEOUT=10

log() {
    echo -e "\033[0;33m[Auto-Handle-Passout]\033[0m $1"
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

log "Starting 2AM passout auto-handler..."
log "Check interval: ${CHECK_INTERVAL}s"

export DISPLAY=:99

log "Waiting for initial game startup..."
sleep 20

LAST_PASSOUT_COUNT=0

if [ -f "$SMAPI_LOG" ]; then
    LAST_PASSOUT_COUNT=$(grep -ciE "passed out|exhausted|collapsed" "$SMAPI_LOG" 2>/dev/null || echo "0")
    log "Initial baseline count: $LAST_PASSOUT_COUNT"
fi

while true; do
    if [ -f "$SMAPI_LOG" ]; then
        CURRENT_PASSOUT_COUNT=$(grep -ciE "passed out|exhausted|collapsed" "$SMAPI_LOG" 2>/dev/null || echo "0")

        if [ "$CURRENT_PASSOUT_COUNT" -gt "$LAST_PASSOUT_COUNT" ]; then
            log "[WARN] New passout event detected ($LAST_PASSOUT_COUNT -> $CURRENT_PASSOUT_COUNT)"
            sleep 3

            if command -v xdotool >/dev/null 2>&1; then
                log "Attempting to confirm passout dialogs..."

                log "  Step 1: close any open menus"
                send_key_locked Escape
                sleep 0.5

                log "  Step 2: press Enter multiple times to confirm dialogs"
                for i in 1 2 3 4 5; do
                    send_key_locked Return
                    sleep 1
                done

                log "[OK] Confirmation keys sent for passout flow"

                sleep 5
                if tail -20 "$SMAPI_LOG" 2>/dev/null | grep -qiE "Saving|woke up|Day [0-9]"; then
                    log "[OK] New day activity detected after passout handling"
                fi
            else
                log "[ERROR] xdotool is not installed, cannot auto-handle passout"
            fi

            LAST_PASSOUT_COUNT=$CURRENT_PASSOUT_COUNT
        fi

        if [ "$CURRENT_PASSOUT_COUNT" -lt "$LAST_PASSOUT_COUNT" ]; then
            log "[INFO] Log rotation detected, resetting passout counter"
            LAST_PASSOUT_COUNT=$CURRENT_PASSOUT_COUNT
        fi
    fi

    sleep $CHECK_INTERVAL
done
