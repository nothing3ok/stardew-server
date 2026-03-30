#!/bin/bash
# Set display resolution for Xorg using xrandr
#
# Usage: set-resolution.sh [WIDTH] [HEIGHT] [REFRESH_RATE]

TARGET_W=${1:-1280}
TARGET_H=${2:-720}
TARGET_R=${3:-60}
TARGET_MODE="${TARGET_W}x${TARGET_H}_${TARGET_R}.00"
SIMPLE_MODE="${TARGET_W}x${TARGET_H}"

echo "[Set-Resolution] Target resolution: ${SIMPLE_MODE} @ ${TARGET_R}Hz"

OUTPUT=$(xrandr | awk '/ connected/ { print $1; exit }' 2>/dev/null || true)

if [ -n "$OUTPUT" ]; then
    echo "[Set-Resolution] Detected output: $OUTPUT, trying ${SIMPLE_MODE} or ${TARGET_MODE}"

    if xrandr --output "$OUTPUT" --mode "$SIMPLE_MODE" >/dev/null 2>&1; then
        echo "[Set-Resolution] [OK] Applied mode ${SIMPLE_MODE} to $OUTPUT"
    else
        if xrandr --output "$OUTPUT" --mode "$TARGET_MODE" >/dev/null 2>&1; then
            echo "[Set-Resolution] [OK] Applied mode ${TARGET_MODE} to $OUTPUT"
        else
            if command -v cvt >/dev/null 2>&1 && command -v xrandr >/dev/null 2>&1; then
                echo "[Set-Resolution] Trying to generate a custom mode via cvt..."
                MODELINE=$(cvt ${TARGET_W} ${TARGET_H} ${TARGET_R} 2>/dev/null | sed -n '2p' | sed 's/Modeline //')
                if [ -n "$MODELINE" ]; then
                    MODE_NAME=$(echo "$MODELINE" | awk '{print $1}' | tr -d \")
                    xrandr --newmode $MODELINE >/dev/null 2>&1 || true
                    xrandr --addmode "$OUTPUT" "$MODE_NAME" >/dev/null 2>&1 || true
                    if xrandr --output "$OUTPUT" --mode "$MODE_NAME" >/dev/null 2>&1; then
                        echo "[Set-Resolution] [OK] Created and applied custom mode $MODE_NAME on $OUTPUT"
                    else
                        echo "[Set-Resolution] [WARN] Could not apply custom mode $MODE_NAME, keeping current resolution"
                    fi
                else
                    echo "[Set-Resolution] [WARN] cvt could not generate a modeline"
                fi
            else
                echo "[Set-Resolution] [WARN] cvt or xrandr is unavailable, keeping current resolution"
            fi
        fi
    fi
else
    echo "[Set-Resolution] [WARN] No connected output detected, skipping resolution change"
fi
