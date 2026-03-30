#!/bin/bash
# VNC Diagnostic Script

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "  VNC Diagnostic Tool"
echo "========================================"
echo ""

echo "[1/8] Checking container status..."
if ! docker ps | grep -q nothing-stardew; then
    echo -e "${RED}[ERROR] Container is not running${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Container is running${NC}"
echo ""

echo "[2/8] Checking VNC environment variable..."
VNC_ENABLED=$(docker exec nothing-stardew env | grep ENABLE_VNC)
echo "ENABLE_VNC setting: $VNC_ENABLED"
if echo "$VNC_ENABLED" | grep -q "true"; then
    echo -e "${GREEN}[OK] VNC is enabled${NC}"
else
    echo -e "${YELLOW}[WARN] VNC may not be enabled${NC}"
fi
echo ""

echo "[3/8] Checking Xvfb (virtual display)..."
docker exec nothing-stardew ps aux | grep -i xvfb | grep -v grep
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[OK] Xvfb is running${NC}"
else
    echo -e "${RED}[ERROR] Xvfb is not running${NC}"
fi
echo ""

echo "[4/8] Checking x11vnc process..."
docker exec nothing-stardew ps aux | grep -i x11vnc | grep -v grep
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[OK] x11vnc is running${NC}"
else
    echo -e "${RED}[ERROR] x11vnc is not running${NC}"
    echo ""
    echo "Possible reasons:"
    echo "  1. VNC is not enabled (set ENABLE_VNC=true in .env)"
    echo "  2. x11vnc failed to start"
    echo "  3. Xvfb was not ready when x11vnc started"
fi
echo ""

echo "[5/8] Checking if port 5900 is listening inside the container..."
docker exec nothing-stardew netstat -tuln 2>/dev/null | grep 5900
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[OK] Port 5900 is listening${NC}"
else
    echo -e "${RED}[ERROR] Port 5900 is not listening${NC}"
fi
echo ""

echo "[6/8] Checking host port mapping..."
docker port nothing-stardew 5900 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[OK] Port 5900 is mapped${NC}"
else
    echo -e "${RED}[ERROR] Port 5900 is not mapped${NC}"
    echo "Start the container with a 5900/tcp port mapping."
fi
echo ""

echo "[7/8] Checking host firewall..."
if command -v ufw >/dev/null 2>&1; then
    ufw status | grep 5900
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[OK] Firewall rule exists${NC}"
    else
        echo -e "${YELLOW}[WARN] No firewall rule found for port 5900${NC}"
        echo "Add one with: sudo ufw allow 5900/tcp"
    fi
else
    echo "ufw not found, skipping firewall check"
fi
echo ""

echo "[8/8] Checking recent VNC-related logs..."
docker logs nothing-stardew 2>&1 | grep -i vnc | tail -5
echo ""

echo "========================================"
echo "  Diagnostic Summary"
echo "========================================"
echo ""
echo "To manually start VNC in the container:"
echo "  docker exec nothing-stardew x11vnc -display :99 -forever -shared -rfbport 5900"
echo ""
echo "To test VNC connection from the host:"
echo "  nc -zv localhost 5900"
echo ""
echo "To view full container logs:"
echo "  docker logs nothing-stardew"
