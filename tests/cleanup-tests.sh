#!/bin/bash
# Cleanup test environment

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Cleaning up test containers and temporary data...${NC}"

docker stop test-steam-guard 2>/dev/null || true
docker rm test-steam-guard 2>/dev/null || true
rm -rf /tmp/steam-guard-test-* 2>/dev/null || true
docker image prune -f >/dev/null 2>&1

echo -e "${GREEN}[OK] Cleanup complete${NC}"
