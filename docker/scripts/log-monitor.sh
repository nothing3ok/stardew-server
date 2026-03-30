#!/bin/bash
# Nothing Stardew Server Log Monitor
#
# Runs in the background and categorizes game log output.

set -e

SMAPI_LOG="/home/steam/.config/StardewValley/ErrorLogs/SMAPI-latest.txt"
OUTPUT_DIR="/home/steam/.local/share/nothing-stardew/logs/categorized"
ERROR_LOG="$OUTPUT_DIR/errors.log"
MOD_LOG="$OUTPUT_DIR/mods.log"
SERVER_LOG="$OUTPUT_DIR/server.log"
GAME_LOG="$OUTPUT_DIR/game.log"

CHECK_INTERVAL=30
BATCH_SIZE=100

mkdir -p "$OUTPUT_DIR"
touch "$ERROR_LOG" "$MOD_LOG" "$SERVER_LOG" "$GAME_LOG"

LAST_LINE=0
if [ -f "$OUTPUT_DIR/.last_line" ]; then
    LAST_LINE=$(cat "$OUTPUT_DIR/.last_line")
fi

process_log_line() {
    local line="$1"
    local timestamp

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    [ -n "$line" ] || return

    if echo "$line" | grep -qE "ERROR|FATAL|Exception"; then
        echo "[$timestamp] $line" >> "$ERROR_LOG"
    fi

    if echo "$line" | grep -qE "\[[0-9]{2}:[0-9]{2}:[0-9]{2}\s+(TRACE|DEBUG|INFO|WARN|ERROR)\s+(Server Auto Load|Skill Level Guard|AutoHideHost|Always On Server|Save Backup)\]"; then
        echo "[$timestamp] $line" >> "$MOD_LOG"
    fi

    if echo "$line" | grep -qEi "Starting LAN server|Starting server\. Protocol|ServerOfflineMode|Multiplayer|Connection|joined the game|left the game|farmhand|player connected|player disconnected|peer .* joined|peer .* left|client .* connected|client .* disconnected"; then
        echo "[$timestamp] $line" >> "$SERVER_LOG"
    fi

    if echo "$line" | grep -qE "\[[0-9]{2}:[0-9]{2}:[0-9]{2}\s+(TRACE|DEBUG|INFO|WARN|ERROR)\s+game\]"; then
        echo "[$timestamp] $line" >> "$GAME_LOG"
    fi
}

monitor_logs() {
    while true; do
        if [ -f "$SMAPI_LOG" ]; then
            local total_lines
            local lines_to_process

            total_lines=$(wc -l < "$SMAPI_LOG" 2>/dev/null || echo "0")

            if [ "$total_lines" -gt "$LAST_LINE" ]; then
                lines_to_process=$((total_lines - LAST_LINE))

                if [ "$lines_to_process" -gt "$BATCH_SIZE" ]; then
                    lines_to_process=$BATCH_SIZE
                fi

                tail -n +"$((LAST_LINE + 1))" "$SMAPI_LOG" | head -n "$lines_to_process" | while IFS= read -r line; do
                    process_log_line "$line"
                done

                LAST_LINE=$((LAST_LINE + lines_to_process))
                echo "$LAST_LINE" > "$OUTPUT_DIR/.last_line"
            fi
        fi

        sleep "$CHECK_INTERVAL"
    done
}

trap 'echo "Log monitor stopped"; exit 0' SIGTERM SIGINT

echo "[Log-Monitor] Starting log monitoring..."
echo "[Log-Monitor] Checking every ${CHECK_INTERVAL}s"
echo "[Log-Monitor] Output directory: $OUTPUT_DIR"

monitor_logs
