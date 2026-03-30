#!/bin/bash
# Key Press Mutex Lock - Shared Library
#
# Prevents multiple scripts from sending keyboard input at the same time.

LOCK_FILE="/tmp/stardew-key-lock"
LOCK_TIMEOUT=10

send_key() {
    local key="$1"
    local script_name="${2:-unknown}"

    (
        if flock -w "$LOCK_TIMEOUT" 200; then
            xdotool key "$key" 2>/dev/null
            return $?
        else
            echo "[key-lock] [WARN] $script_name: failed to acquire lock for key '$key'" >&2
            return 1
        fi
    ) 200>"$LOCK_FILE"
}

send_keys() {
    local script_name="${1:-unknown}"
    shift
    local keys=("$@")

    (
        if flock -w "$LOCK_TIMEOUT" 200; then
            for key in "${keys[@]}"; do
                xdotool key "$key" 2>/dev/null
                sleep 0.1
            done
            return 0
        else
            echo "[key-lock] [WARN] $script_name: failed to acquire lock for key sequence" >&2
            return 1
        fi
    ) 200>"$LOCK_FILE"
}

export -f send_key
export -f send_keys
