#!/bin/bash
# Nothing Stardew Server - One-Click Update Script
#
# Usage: ./update.sh [version]
# Example:
#   ./update.sh
#   ./update.sh v1.0.65

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

IMAGE="truemanlive/nothing-stardew-server"
CONTAINER="nothing-stardew"
VERSION="${1:-latest}"
BACKUP_FILE=""

log_info() { echo -e "${GREEN}[Update]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[Update]${NC} $1"; }
log_error() { echo -e "${RED}[Update]${NC} $1"; }
log_step() { echo -e "${BLUE}$1${NC}"; }

log_step "========================================"
log_step "  Nothing Stardew Server Updater"
log_step "========================================"
echo ""

log_info "Step 1: Checking current version..."
CURRENT_IMAGE=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER" 2>/dev/null)
if [ -n "$CURRENT_IMAGE" ]; then
    log_info "Current image: $CURRENT_IMAGE"
else
    log_warn "Container not found"
fi
log_info "Target image: $IMAGE:$VERSION"
echo ""

log_info "Step 2: Backing up saves..."
BACKUP_DIR="backups"
mkdir -p "$BACKUP_DIR"

if [ -d "data/saves" ]; then
    BACKUP_FILE="$BACKUP_DIR/saves-pre-update-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar -czf "$BACKUP_FILE" data/saves/ 2>/dev/null || true
    if [ -f "$BACKUP_FILE" ]; then
        log_info "Backup saved to: $BACKUP_FILE"
    else
        log_warn "Backup failed, continuing anyway"
    fi
else
    log_warn "No saves directory found"
fi
echo ""

log_info "Step 3: Stopping server..."
if docker ps -q -f name="$CONTAINER" | grep -q .; then
    docker compose down 2>/dev/null || docker-compose down 2>/dev/null || docker stop "$CONTAINER" 2>/dev/null
    log_info "Server stopped"
else
    log_info "Server is not currently running"
fi
echo ""

log_info "Step 4: Pulling image $IMAGE:$VERSION..."
docker pull "$IMAGE:$VERSION"
if [ $? -ne 0 ]; then
    log_error "Failed to pull image"
    log_error "Check your network connection and image name"
    exit 1
fi
log_info "Image pulled successfully"
echo ""

if [ "$VERSION" != "latest" ]; then
    log_info "Step 5: Updating docker-compose.yml image tag..."
    if [ -f "docker-compose.yml" ]; then
        sed -i "s|image: ${IMAGE}:.*|image: ${IMAGE}:${VERSION}|" docker-compose.yml
        log_info "docker-compose.yml updated to $VERSION"
    fi
else
    log_info "Step 5: Using latest tag, compose file unchanged"
fi
echo ""

log_info "Step 6: Starting server..."
docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null
if [ $? -ne 0 ]; then
    log_error "Failed to start server"
    exit 1
fi
log_info "Server started"

sleep 2
INIT_EXIT=$(docker inspect --format='{{.State.ExitCode}}' nothing-stardew-init 2>/dev/null || true)
if [ -n "$INIT_EXIT" ] && [ "$INIT_EXIT" != "0" ]; then
    log_warn "Init container exit code: $INIT_EXIT"
    log_warn "Check logs: docker logs nothing-stardew-init"
fi
echo ""

log_info "Step 7: Verifying update..."
sleep 3
NEW_IMAGE=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER" 2>/dev/null || echo "unknown")
INIT_STATUS=$(docker inspect --format='{{.State.Status}}' nothing-stardew-init 2>/dev/null || echo "unknown")
log_info "Running image: $NEW_IMAGE"
log_info "Init container status: $INIT_STATUS"
echo ""

log_info "Cleaning up old images..."
docker image prune -f --filter "label=maintainer=truemanlive" 2>/dev/null || true
echo ""

log_step "========================================"
log_step "  [OK] Update complete"
log_step "========================================"
log_info "Check logs with: docker logs -f $CONTAINER"
if [ -n "$BACKUP_FILE" ]; then
    log_info "Backup location: $BACKUP_FILE"
fi
echo ""
