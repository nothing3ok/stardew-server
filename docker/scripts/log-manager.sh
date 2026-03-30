#!/bin/bash
# Nothing Stardew Server Log Manager
#
# Features:
# - Automatic log rotation and compression
# - Retention policy for current logs and archives
# - Low runtime overhead
# - Archived summary output

set -e

LOG_BASE_DIR="/home/steam/.config/StardewValley/ErrorLogs"
ARCHIVE_DIR="/home/steam/.local/share/nothing-stardew/logs/archive"
KEEP_DAYS=7
ARCHIVE_DAYS=30
MAX_LOG_SIZE_MB=50

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[Log-Manager]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[Log-Manager]${NC} $1"
}

mkdir -p "$ARCHIVE_DIR"

rotate_log() {
    local log_file="$1"
    local log_name
    local timestamp

    log_name=$(basename "$log_file")
    timestamp=$(date +%Y%m%d_%H%M%S)

    if [ -f "$log_file" ]; then
        local size_mb
        size_mb=$(du -m "$log_file" | cut -f1)

        if [ "$size_mb" -ge "$MAX_LOG_SIZE_MB" ]; then
            log_info "Rotating $log_name (${size_mb}MB)"
            gzip -c "$log_file" > "$ARCHIVE_DIR/${log_name%.txt}_${timestamp}.txt.gz"
            > "$log_file"
            log_info "Archived to ${log_name%.txt}_${timestamp}.txt.gz"
        fi
    fi
}

clean_old_logs() {
    log_info "Cleaning old log archives..."
    find "$LOG_BASE_DIR" -name "*.txt" -type f -mtime +$KEEP_DAYS -delete 2>/dev/null || true
    find "$ARCHIVE_DIR" -name "*.gz" -type f -mtime +$ARCHIVE_DAYS -delete 2>/dev/null || true
    find "$ARCHIVE_DIR" -type d -empty -delete 2>/dev/null || true
    log_info "Cleanup complete"
}

generate_summary() {
    local log_file="$LOG_BASE_DIR/SMAPI-latest.txt"

    if [ ! -f "$log_file" ]; then
        return
    fi

    log_info "Generating log summary..."

    mkdir -p "$ARCHIVE_DIR"

    local error_count
    local warn_count
    local recent_errors
    local summary_file

    error_count=$(grep -c "ERROR" "$log_file" 2>/dev/null || echo "0")
    warn_count=$(grep -c "WARN" "$log_file" 2>/dev/null || echo "0")
    recent_errors=$(grep "ERROR" "$log_file" 2>/dev/null | tail -5 || echo "")
    summary_file="$ARCHIVE_DIR/summary_$(date +%Y%m%d).txt"

    {
        echo "=== Nothing Stardew Server Log Summary ==="
        echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        echo "Statistics:"
        echo "  Errors: $error_count"
        echo "  Warnings: $warn_count"
        echo ""
        if [ -n "$recent_errors" ]; then
            echo "Recent Errors:"
            echo "$recent_errors"
        fi
        echo ""
        echo "Full logs available in: $ARCHIVE_DIR"
    } > "$summary_file"

    log_info "Summary saved to $summary_file"
}

log_info "Starting log management cycle..."
rotate_log "$LOG_BASE_DIR/SMAPI-latest.txt"
clean_old_logs
generate_summary

log_info "Log disk usage:"
echo "  Current logs: $(du -sh "$LOG_BASE_DIR" 2>/dev/null | cut -f1 || echo "0K")"
echo "  Archives: $(du -sh "$ARCHIVE_DIR" 2>/dev/null | cut -f1 || echo "0K")"

log_info "Log management complete"
