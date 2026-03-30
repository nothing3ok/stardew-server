#!/bin/bash
# Nothing Stardew Server - Log Viewer
#
# Usage: docker exec -it nothing-stardew /home/steam/scripts/view-logs.sh [option]

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

CATEGORIZED_DIR="/home/steam/.local/share/nothing-stardew/logs/categorized"
ARCHIVE_DIR="/home/steam/.local/share/nothing-stardew/logs/archive"

show_menu() {
    echo -e "${GREEN}=== Nothing Stardew Server Log Viewer ===${NC}"
    echo ""
    echo "1) View all errors"
    echo "2) View mod logs"
    echo "3) View server logs"
    echo "4) View game logs"
    echo "5) Show log statistics"
    echo "6) View archived logs"
    echo "7) Tail live game log"
    echo "0) Exit"
    echo ""
    read -p "Select option: " option

    case $option in
        1)
            if [ -f "$CATEGORIZED_DIR/errors.log" ]; then
                echo -e "${RED}=== Error Logs ===${NC}"
                tail -50 "$CATEGORIZED_DIR/errors.log"
            else
                echo -e "${YELLOW}No error logs found.${NC}"
            fi
            ;;
        2)
            if [ -f "$CATEGORIZED_DIR/mods.log" ]; then
                echo -e "${BLUE}=== Mod Logs ===${NC}"
                tail -50 "$CATEGORIZED_DIR/mods.log"
            else
                echo -e "${YELLOW}No mod logs found.${NC}"
            fi
            ;;
        3)
            if [ -f "$CATEGORIZED_DIR/server.log" ]; then
                echo -e "${GREEN}=== Server Logs ===${NC}"
                tail -50 "$CATEGORIZED_DIR/server.log"
            else
                echo -e "${YELLOW}No server logs found.${NC}"
            fi
            ;;
        4)
            if [ -f "$CATEGORIZED_DIR/game.log" ]; then
                echo -e "${BLUE}=== Game Logs ===${NC}"
                tail -50 "$CATEGORIZED_DIR/game.log"
            else
                echo -e "${YELLOW}No game logs found.${NC}"
            fi
            ;;
        5)
            echo -e "${GREEN}=== Log Statistics ===${NC}"
            echo ""
            echo "Disk usage:"
            if [ -d "$CATEGORIZED_DIR" ]; then
                echo "  Current logs: $(du -sh "$CATEGORIZED_DIR" 2>/dev/null | cut -f1 || echo '0K')"
            fi
            if [ -d "$ARCHIVE_DIR" ]; then
                echo "  Archives: $(du -sh "$ARCHIVE_DIR" 2>/dev/null | cut -f1 || echo '0K')"
            fi
            echo ""
            if [ -f "$CATEGORIZED_DIR/errors.log" ]; then
                echo "Error count: $(wc -l < "$CATEGORIZED_DIR/errors.log" 2>/dev/null || echo '0')"
            fi
            if [ -f "$CATEGORIZED_DIR/mods.log" ]; then
                echo "Mod entries: $(wc -l < "$CATEGORIZED_DIR/mods.log" 2>/dev/null || echo '0')"
            fi
            ;;
        6)
            echo -e "${BLUE}=== Archived Logs ===${NC}"
            if [ -d "$ARCHIVE_DIR" ]; then
                ls -lh "$ARCHIVE_DIR"/*.gz 2>/dev/null | tail -20 || echo "No archived logs found."
            else
                echo "No archive directory found."
            fi
            ;;
        7)
            echo -e "${GREEN}=== Live Game Log ===${NC}"
            echo "Press Ctrl+C to stop"
            tail -f /home/steam/.config/StardewValley/ErrorLogs/SMAPI-latest.txt 2>/dev/null || echo "Log file not found"
            ;;
        0)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac

    echo ""
    read -p "Press ENTER to continue..."
    show_menu
}

if [ "$(whoami)" != "steam" ]; then
    echo -e "${YELLOW}Warning: this script is intended to run as the steam user.${NC}"
    echo "Use: docker exec -it nothing-stardew /home/steam/scripts/view-logs.sh"
fi

show_menu
