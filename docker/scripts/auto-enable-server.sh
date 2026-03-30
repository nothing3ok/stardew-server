#!/bin/bash
# Auto-Enable Always On Server - Background Script
#
# Uses xdotool to simulate the F9 key and enable Always On Server when needed.

SMAPI_LOG="/home/steam/.config/StardewValley/ErrorLogs/SMAPI-latest.txt"
MAX_WAIT=120
CHECK_INTERVAL=2
LOCK_FILE="/tmp/stardew-key-lock"
LOCK_TIMEOUT=10

log() {
    echo -e "\033[0;36m[Auto-Enable-Server]\033[0m $1"
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

log "Starting Always On Server auto-enable service..."
log "Waiting for initial game startup..."
sleep 10

log "Waiting for save load completion..."

elapsed=0
while [ $elapsed -lt $MAX_WAIT ]; do
    if [ -f "$SMAPI_LOG" ]; then
        if grep -q "SAVE LOADED SUCCESSFULLY\|Context: loaded save" "$SMAPI_LOG" 2>/dev/null; then
            log "[OK] Save load detected"
            log "Waiting a few more seconds for mod initialization..."
            sleep 5

            log "Checking current Always On Server state..."
            ON_COUNT=$(grep -o "Auto [Mm]ode [Oo]n" "$SMAPI_LOG" 2>/dev/null | wc -l)
            OFF_COUNT=$(grep -o "Auto mode off" "$SMAPI_LOG" 2>/dev/null | wc -l)

            log "  Detected 'Auto Mode On' count: $ON_COUNT"
            log "  Detected 'Auto mode off' count: $OFF_COUNT"

            if [ "$ON_COUNT" -gt "$OFF_COUNT" ]; then
                log "[OK] Always On Server already appears to be enabled"
                log "No F9 keypress needed"
                exit 0
            elif [ "$ON_COUNT" -eq "$OFF_COUNT" ] && [ "$ON_COUNT" -gt 0 ]; then
                log "[WARN] Always On Server may currently be off"
                log "Trying F9 to re-enable it..."
            else
                log "[INFO] Always On Server state is unknown"
                log "Trying F9 to enable it..."
            fi

            export DISPLAY=:99

            if command -v xdotool >/dev/null 2>&1; then
                log "Preparing to enable Always On Server..."

                for attempt in 1 2 3; do
                    log "  Attempt #$attempt: closing menus and pressing F9..."

                    for i in 1 2 3; do
                        send_key_locked Escape
                        sleep 0.3
                    done

                    sleep 1
                    send_key_locked F9
                    log "  [OK] F9 key sent (attempt #$attempt)"
                    sleep 5

                    ON_COUNT_AFTER=$(grep -o "Auto [Mm]ode [Oo]n" "$SMAPI_LOG" 2>/dev/null | wc -l)
                    OFF_COUNT_AFTER=$(grep -o "Auto mode off" "$SMAPI_LOG" 2>/dev/null | wc -l)

                    log "  State check: ON=$ON_COUNT_AFTER, OFF=$OFF_COUNT_AFTER"

                    if [ "$ON_COUNT_AFTER" -gt "$OFF_COUNT_AFTER" ]; then
                        log "[OK] Always On Server enabled successfully"
                        exit 0
                    fi

                    if [ "$attempt" -lt 3 ]; then
                        log "  Not enabled yet, retrying in 10 seconds..."
                        sleep 10
                    fi
                done

                log "[WARN] Auto Mode On was not detected after 3 attempts"
                log "Possible causes:"
                log "  1. Always On Server was enabled in another way"
                log "  2. A game menu is still blocking key input"
                log "  3. xdotool is not working in the current virtual display"
                log "You may need to press F9 manually via VNC"
                exit 0
            else
                log "[ERROR] xdotool is not installed"
                exit 1
            fi
        fi
    fi

    sleep $CHECK_INTERVAL
    elapsed=$((elapsed + CHECK_INTERVAL))
done

log "[WARN] Timed out after ${MAX_WAIT} seconds without detecting a loaded save"
log "Always On Server may not have been auto-enabled"
exit 1
