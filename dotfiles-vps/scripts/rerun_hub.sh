#!/usr/bin/env bash
set -euo pipefail

HUB_HOST="api.getrivet.app"
HUB_SERVER_PORT=8080
HUB_DB_PATH="/var/lib/rivet/hub.db"

CADDY_ADMIN_URL="http://caddy:2019"

BASE_DIR="$HOME/rivet"
DATA_DIR="$BASE_DIR/data"

RIVET_RUNTIME_NETWORK=rivet_runtime

echo "Ensuring base directory..."
mkdir -p "$BASE_DIR" "$DATA_DIR"

echo "Loading new hub image..."
gunzip -c "$BASE_DIR/rivet-images.tar.gz" | docker load

echo "Creating network if not exists..."
docker network inspect $RIVET_RUNTIME_NETWORK >/dev/null 2>&1 || docker network create $RIVET_RUNTIME_NETWORK

echo "Stopping old hub container if it exists..."
docker rm -f hub >/dev/null 2>&1 || true

docker container prune -f
docker image prune -f

echo "Starting new hub container..."
docker run -d \
  --name hub \
  --network $RIVET_RUNTIME_NETWORK \
  --user 0:0 \
  -e HUB_HOST="${HUB_HOST}" \
  -e HUB_SERVER_PORT="${HUB_SERVER_PORT}" \
  -e HUB_DB_PATH="${HUB_DB_PATH}" \
  -e CADDY_ADMIN_URL="${CADDY_ADMIN_URL}" \
  -e RIVET_RUNTIME_NETWORK="${RIVET_RUNTIME_NETWORK}" \
  -v "$DATA_DIR:/var/lib/rivet" \
  -v "/var/run/docker.sock:/var/run/docker.sock" \
  --restart unless-stopped \
  rivet-hub:latest

echo "Ensuring hub data directory is writable..."
sudo chown -R 0:0 "$DATA_DIR"

echo "Cleaning up temp artifacts..."
rm -f "$BASE_DIR/rivet-images.tar.gz"

echo "Done"
