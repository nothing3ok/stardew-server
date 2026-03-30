#!/bin/bash
# Save Selector - Select which save to load

SAVE_DIR="/home/steam/.config/StardewValley/Saves"
SAVE_NAME="${SAVE_NAME:-}"

log() {
    echo -e "\033[0;32m[Save-Selector]\033[0m $1"
}

if [ -n "$SAVE_NAME" ]; then
    log "Requested save name: $SAVE_NAME"

    if [ -d "$SAVE_DIR/$SAVE_NAME" ]; then
        log "[OK] Save found: $SAVE_NAME"
        mkdir -p "$SAVE_DIR"
        echo "$SAVE_NAME" > "$SAVE_DIR/.selected_save"
        log "[OK] Auto-load save set to: $SAVE_NAME"
    else
        log "[WARN] Save not found: $SAVE_NAME"
        log "Available saves:"
        if [ -d "$SAVE_DIR" ]; then
            ls -1 "$SAVE_DIR" 2>/dev/null | grep -v "^\." | while read -r save; do
                log "  - $save"
            done
        fi
        log "Falling back to default save auto-load behavior"
    fi
else
    log "No save name specified, using default auto-load behavior"
fi
