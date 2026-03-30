#!/bin/bash
# Player Access Control - whitelist/blacklist management.
#
# Monitors SMAPI logs for player connections and alerts when a player should
# be blocked according to the whitelist or blacklist configuration.

CONFIG_FILE="/home/steam/.config/StardewValley/player-access.conf"
SMAPI_LOG="/home/steam/.config/StardewValley/ErrorLogs/SMAPI-latest.txt"
CHECK_INTERVAL=5

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()      { echo -e "${GREEN}[Access-Control]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[Access-Control]${NC} $1"; }
log_err()  { echo -e "${RED}[Access-Control]${NC} $1"; }

create_default_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" <<'EOCONF'
# Player Access Control Configuration
#
# MODE options:
#   disabled  - No access control (allow all players)
#   whitelist - Only listed players can join
#   blacklist - Listed players are blocked
#
# Add one player name per line below the MODE setting.
#
# Example (whitelist mode):
#   MODE=whitelist
#   Alice
#   Bob
#
# Example (blacklist mode):
#   MODE=blacklist
#   Griefer123
#   BadPlayer

MODE=disabled
EOCONF
        log "Created default config: $CONFIG_FILE"
    fi
}

load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "disabled"
        return
    fi

    local mode
    mode=$(grep -m1 "^MODE=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2 | tr -d '[:space:]')
    echo "${mode:-disabled}"
}

get_player_list() {
    if [ ! -f "$CONFIG_FILE" ]; then
        return
    fi

    grep -v "^#" "$CONFIG_FILE" | grep -v "^MODE=" | grep -v "^$" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | while read -r line; do
        [ -n "$line" ] && echo "$line"
    done
}

player_in_list() {
    local player_name="$1"
    local found=1

    while read -r listed_player; do
        if [ "$listed_player" = "$player_name" ]; then
            found=0
            break
        fi
    done < <(get_player_list)

    return $found
}

should_allow_player() {
    local player_name="$1"
    local mode

    mode=$(load_config)

    case "$mode" in
        disabled)
            return 0
            ;;
        whitelist)
            if player_in_list "$player_name"; then
                return 0
            else
                return 1
            fi
            ;;
        blacklist)
            if player_in_list "$player_name"; then
                return 1
            else
                return 0
            fi
            ;;
        *)
            return 0
            ;;
    esac
}

monitor_connections() {
    local last_line_count=0

    while true; do
        if [ ! -f "$SMAPI_LOG" ]; then
            sleep "$CHECK_INTERVAL"
            continue
        fi

        local current_line_count
        current_line_count=$(wc -l < "$SMAPI_LOG" 2>/dev/null || echo "0")

        if [ "$current_line_count" -gt "$last_line_count" ]; then
            local new_lines
            new_lines=$(tail -n +$((last_line_count + 1)) "$SMAPI_LOG" 2>/dev/null)

            echo "$new_lines" | grep -iE "farmhand connected|player connected|joined the game" | while read -r line; do
                local player_name
                local mode

                player_name=$(echo "$line" | grep -oP "(?:farmhand|player)\s+(\S+)\s+connected" | awk '{print $2}')

                if [ -z "$player_name" ]; then
                    player_name=$(echo "$line" | grep -oP "'([^']+)'\s+(?:connected|joined)" | sed "s/'//g" | awk '{print $1}')
                fi

                if [ -n "$player_name" ]; then
                    mode=$(load_config)

                    if ! should_allow_player "$player_name"; then
                        log_err "BLOCKED player: $player_name (mode: $mode)"
                        log_warn "Use SMAPI console or a kick mod to remove this player."
                    else
                        log "Player allowed: $player_name (mode: $mode)"
                    fi
                fi
            done

            last_line_count=$current_line_count
        fi

        sleep "$CHECK_INTERVAL"
    done
}

create_default_config

MODE=$(load_config)
log "Access control mode: $MODE"

if [ "$MODE" = "disabled" ]; then
    log "Access control disabled, monitoring skipped"
    exit 0
fi

PLAYER_COUNT=$(get_player_list | wc -l)
log "Player list: $PLAYER_COUNT entries"
log "Starting connection monitor..."

monitor_connections
