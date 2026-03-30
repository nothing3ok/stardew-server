#!/bin/bash
# Nothing Stardew Server - Initialization Script
#
# This script creates the required data directories and fixes permissions.

set -e

echo "=========================================="
echo "Nothing Stardew Server - Initialization"
echo "=========================================="
echo ""

if [ "$EUID" -eq 0 ]; then
    SUDO=""
    echo "[OK] Running as root"
else
    SUDO="sudo"
    echo "[INFO] Running as non-root user, sudo will be used for permission changes"
fi

echo ""
echo "Creating data directories..."
mkdir -p data/{saves,game,steam,logs,backups,custom-mods,panel}
echo "[OK] Directories created:"
echo "     data/saves, data/game, data/steam, data/logs, data/backups, data/custom-mods, data/panel"

echo ""
echo "Setting permissions (UID 1000:1000)..."
$SUDO chown -R 1000:1000 data/

GAME_UID=$(stat -c '%u' data/game 2>/dev/null || stat -f '%u' data/game 2>/dev/null)
if [ "$GAME_UID" != "1000" ]; then
    echo "[ERROR] Failed to set permissions."
    echo ""
    echo "This can cause 'Disk write failure' when downloading game files."
    echo "Try running: sudo chown -R 1000:1000 data/"
    echo ""
    exit 1
fi

echo "[OK] Permissions set successfully"

echo ""
echo "Verifying directory layout..."
ls -la data/
echo ""

echo "=========================================="
echo "[OK] Initialization complete"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Configure .env with your Steam credentials"
echo "  2. Run: docker compose up -d"
echo ""
