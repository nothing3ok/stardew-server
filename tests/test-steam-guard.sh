#!/bin/bash
# Steam Guard flow test script.

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Steam Guard Flow Test${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ -z "$STEAM_USERNAME" ] || [ -z "$STEAM_PASSWORD" ]; then
    echo -e "${RED}ERROR: STEAM_USERNAME or STEAM_PASSWORD not set${NC}"
    echo "Please set environment variables:"
    echo "  export STEAM_USERNAME=your_username"
    echo "  export STEAM_PASSWORD=your_password"
    exit 1
fi

echo -e "${GREEN}[OK] Steam credentials found${NC}"
echo -e "  Username: $STEAM_USERNAME"
echo ""

echo -e "${YELLOW}[1/5] Cleaning up old test containers...${NC}"
docker stop test-steam-guard 2>/dev/null || true
docker rm test-steam-guard 2>/dev/null || true
echo -e "${GREEN}[OK] Cleanup complete${NC}"
echo ""

echo -e "${YELLOW}[2/5] Setting up test directories...${NC}"
TEST_DIR="/tmp/steam-guard-test-$(date +%s)"
mkdir -p "$TEST_DIR"/{saves,game,steam}
echo -e "${GREEN}[OK] Test directory: $TEST_DIR${NC}"
echo ""

echo -e "${YELLOW}[3/5] Starting test container...${NC}"
docker run -d \
  --name test-steam-guard \
  -it \
  -e STEAM_USERNAME="$STEAM_USERNAME" \
  -e STEAM_PASSWORD="$STEAM_PASSWORD" \
  -e ENABLE_VNC=false \
  -v "$TEST_DIR/saves:/home/steam/.config/StardewValley:rw" \
  -v "$TEST_DIR/game:/home/steam/stardewvalley:rw" \
  -v "$TEST_DIR/steam:/home/steam/Steam:rw" \
  truemanlive/nothing-stardew-server:latest

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR] Failed to start container${NC}"
    exit 1
fi

echo -e "${GREEN}[OK] Container started${NC}"
echo ""

echo -e "${YELLOW}[4/5] Waiting for Steam Guard prompt (30s)...${NC}"
sleep 30
echo ""

echo -e "${YELLOW}[5/5] Checking logs for Steam Guard prompt...${NC}"
LOG=$(docker logs test-steam-guard 2>&1)

if echo "$LOG" | grep -q "STEAM GUARD CODE REQUIRED"; then
    echo -e "${GREEN}[OK] Steam Guard prompt detected${NC}"
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  ACTION REQUIRED${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    echo "Steam Guard authentication is required."
    echo ""
    echo "To continue:"
    echo -e "  1. Run: ${GREEN}docker attach test-steam-guard${NC}"
    echo "  2. Enter your Steam Guard code when prompted"
    echo "  3. Press ENTER"
    echo -e "  4. Detach: ${GREEN}Ctrl+P, Ctrl+Q${NC}"
    echo ""
    echo -e "Monitor logs: ${GREEN}docker logs -f test-steam-guard${NC}"
    echo ""

    read -p "Press ENTER after you've entered the Steam Guard code..."

    sleep 10
    LOG=$(docker logs test-steam-guard 2>&1)

    if echo "$LOG" | grep -q "Game downloaded successfully"; then
        echo -e "${GREEN}[PASS] TEST PASSED${NC}"
        echo -e "${GREEN}Steam Guard flow works correctly.${NC}"
        echo ""
        echo "Cleaning up test container..."
        docker stop test-steam-guard
        docker rm test-steam-guard
        echo -e "${GREEN}[OK] Test complete${NC}"
        exit 0
    else
        echo -e "${YELLOW}[WARN] Game download status unclear${NC}"
        echo "Showing last 20 lines of log:"
        echo "$LOG" | tail -20
        echo ""
        echo "Test container left running for inspection"
        echo "Remove with: docker stop test-steam-guard && docker rm test-steam-guard"
        exit 1
    fi
elif echo "$LOG" | grep -q "Game downloaded successfully"; then
    echo -e "${GREEN}[OK] Game downloaded without Steam Guard${NC}"
    echo -e "${GREEN}[PASS] TEST PASSED${NC}"
    echo ""
    echo "Cleaning up..."
    docker stop test-steam-guard
    docker rm test-steam-guard
    exit 0
else
    echo -e "${RED}[ERROR] Unexpected state${NC}"
    echo "Last 30 lines of log:"
    echo "$LOG" | tail -30
    echo ""
    echo "Test container left running for inspection"
    echo "Remove with: docker stop test-steam-guard && docker rm test-steam-guard"
    exit 1
fi
