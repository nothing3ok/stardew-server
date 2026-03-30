#!/bin/bash
# Auto-Backup - Automatic Save File Backup
#
# Runs daily at the configured time and keeps a configurable number of backups.

SAVE_DIR="/home/steam/.config/StardewValley"
BACKUP_DIR="/home/steam/.local/share/nothing-stardew/backups"
MAX_BACKUPS=${MAX_BACKUPS:-7}
BACKUP_HOUR=${BACKUP_HOUR:-4}
BACKUP_COMPRESSION_LEVEL=${BACKUP_COMPRESSION_LEVEL:-1}
CHECK_INTERVAL=300

GREEN='\033[0;32m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[Auto-Backup]${NC} $1"
}

log "========================================"
log "  Auto-Backup Service Starting..."
log "========================================"
log "  Backup directory: $BACKUP_DIR"
log "  Max backups: $MAX_BACKUPS"
log "  Backup hour: ${BACKUP_HOUR}:00"
log "  Compression level: $BACKUP_COMPRESSION_LEVEL"
log ""

mkdir -p "$BACKUP_DIR"
LAST_BACKUP_DATE=""

do_backup() {
    local timestamp
    local backup_file
    local file_count
    local size
    local backup_count

    timestamp=$(date +%Y%m%d-%H%M%S)
    backup_file="$BACKUP_DIR/saves-$timestamp.tar.gz"

    log "Starting backup..."

    if [ ! -d "$SAVE_DIR/Saves" ] && [ ! -d "$SAVE_DIR" ]; then
        log "[WARN] Save files not found, skipping backup"
        return 1
    fi

    file_count=$(find "$SAVE_DIR" -type f 2>/dev/null | wc -l)
    log "  Save files detected: $file_count"

    tar -I "gzip -${BACKUP_COMPRESSION_LEVEL}" -cf "$backup_file" -C "$(dirname "$SAVE_DIR")" "$(basename "$SAVE_DIR")" 2>/dev/null
    if [ $? -ne 0 ]; then
        log "[ERROR] Backup failed"
        rm -f "$backup_file" 2>/dev/null
        return 1
    fi

    size=$(du -h "$backup_file" 2>/dev/null | cut -f1)
    log "[OK] Backup complete: $backup_file ($size)"

    backup_count=$(ls -1t "$BACKUP_DIR"/saves-*.tar.gz 2>/dev/null | wc -l)
    if [ "$backup_count" -gt "$MAX_BACKUPS" ]; then
        local to_delete=$((backup_count - MAX_BACKUPS))
        log "  Cleaning old backups ($to_delete)..."
        ls -1t "$BACKUP_DIR"/saves-*.tar.gz | tail -n "$to_delete" | xargs rm -f
        log "  [OK] Old backups removed"
    fi

    log "  Current backups: $(ls -1 "$BACKUP_DIR"/saves-*.tar.gz 2>/dev/null | wc -l) / $MAX_BACKUPS"
    LAST_BACKUP_DATE=$(date +%Y%m%d)
    return 0
}

log "Waiting for initial game startup..."
sleep 60

log "Running startup backup..."
do_backup

while true; do
    CURRENT_HOUR=$(date +%H)
    CURRENT_DATE=$(date +%Y%m%d)

    if [ "$CURRENT_HOUR" = "$(printf '%02d' $BACKUP_HOUR)" ] && [ "$CURRENT_DATE" != "$LAST_BACKUP_DATE" ]; then
        log "[INFO] Reached scheduled backup time (${BACKUP_HOUR}:00)"
        do_backup
    fi

    sleep $CHECK_INTERVAL
done
