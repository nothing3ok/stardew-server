#!/bin/bash
# =============================================================================
# Nothing Stardew Server - Backup Script
# =============================================================================
# This script backs up your Stardew Valley save files.
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Configuration
SAVES_DIR="./data/saves"
BACKUP_DIR="./backups"
MAX_BACKUPS=7
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="stardew-backup-$TIMESTAMP.tar.gz"

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}==================================================================${NC}"
    echo -e "${CYAN}${BOLD}  Nothing Stardew Server - Backup${NC}"
    echo -e "${CYAN}${BOLD}==================================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[OK] $1${NC}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[WARN] $1${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

check_saves_dir() {
    if [ ! -d "$SAVES_DIR" ]; then
        print_error "Saves directory not found: $SAVES_DIR"
        echo ""
        echo "Make sure you are running this script from the stardew-server directory."
        exit 1
    fi

    if [ -z "$(ls -A "$SAVES_DIR" 2>/dev/null)" ]; then
        print_warning "Saves directory is empty."
        echo ""
        echo "No save files were found. Create or import a save first."
        exit 1
    fi
}

create_backup() {
    mkdir -p "$BACKUP_DIR"

    print_info "Creating backup: $BACKUP_FILE"
    tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C data saves

    backup_size=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
    print_success "Backup created: $BACKUP_FILE ($backup_size)"
}

cleanup_old_backups() {
    backup_count=$(ls -1 "$BACKUP_DIR"/stardew-backup-*.tar.gz 2>/dev/null | wc -l)

    if [ "$backup_count" -gt "$MAX_BACKUPS" ]; then
        print_info "Cleaning up old backups (keeping last $MAX_BACKUPS)..."
        ls -t "$BACKUP_DIR"/stardew-backup-*.tar.gz | tail -n +$((MAX_BACKUPS + 1)) | xargs rm -f
        print_success "Old backups removed"
    fi
}

list_backups() {
    echo ""
    echo -e "${BOLD}Available backups:${NC}"
    echo ""

    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        print_info "No backups found yet."
        return
    fi

    ls -lth "$BACKUP_DIR"/stardew-backup-*.tar.gz | awk '{
        size = $5
        date = $6 " " $7 " " $8
        file = $9
        gsub(/.*\//, "", file)
        printf "  - %-40s %8s  %s\n", file, size, date
    }'

    echo ""
    total_size=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
    echo -e "${BLUE}Total backup size: $total_size${NC}"
}

show_restore_instructions() {
    echo ""
    echo -e "${BOLD}To restore a backup:${NC}"
    echo ""
    echo "1. Stop the server:"
    echo "   ${CYAN}docker compose down${NC}"
    echo ""
    echo "2. Back up current saves just in case:"
    echo "   ${CYAN}mv data/saves data/saves.old${NC}"
    echo ""
    echo "3. Extract the backup:"
    echo "   ${CYAN}tar -xzf backups/BACKUP_FILE_NAME -C data${NC}"
    echo ""
    echo "4. Start the server again:"
    echo "   ${CYAN}docker compose up -d${NC}"
    echo ""
}

main() {
    print_header
    check_saves_dir
    create_backup
    cleanup_old_backups
    list_backups
    show_restore_instructions

    echo -e "${GREEN}${BOLD}[OK] Backup complete!${NC}"
    echo ""
}

main
