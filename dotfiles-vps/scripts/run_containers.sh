#!/usr/bin/env bash
set -euo pipefail

HUB_HOST="api.getrivet.app"
HUB_SERVER_PORT=8080
HUB_DB_PATH="/var/lib/rivet/hub.db"

CADDY_DATA_DIR="$BASE_DIR/caddy"
CADDY_ADMIN_URL="http://caddy:2019"

BASE_DIR="$HOME/rivet"
DATA_DIR="$BASE_DIR/data"

NETWORK_NAME=rivet_runtime

echo "Ensuring base directory..."
mkdir -p "$BASE_DIR" "$DATA_DIR"

echo "Ensuring hub data directory is writable..."
sudo chown -R 65532:65532 "$DATA_DIR"

echo "Loading new hub image..."
gunzip -c "$BASE_DIR/rivet-images.tar.gz" | docker load

echo "Creating network if not exists..."
docker network inspect $NETWORK_NAME >/dev/null 2>&1 || docker network create $NETWORK_NAME

echo "Stopping old containers if they exist..."
docker rm -f hub caddy >/dev/null 2>&1 || true

docker container prune -f
docker image prune -f

echo "Starting hub..."
docker run -d \
  --name hub \
  --network $NETWORK_NAME \
  --user 0:0 \
  -e HUB_SERVER_PORT="${HUB_SERVER_PORT}" \
  -e CADDY_ADMIN_URL="${CADDY_ADMIN_URL}" \
  -e HUB_DB_PATH="${HUB_DB_PATH}" \
  -v "$DATA_DIR:/var/lib/rivet" \
  -v "/var/run/docker.sock:/var/run/docker.sock" \
  --restart unless-stopped \
  rivet-hub:latest

echo "Checking Caddyfile..."
if [ ! -f "$BASE_DIR/Caddyfile" ]; then
  echo "Caddyfile not found at $BASE_DIR/Caddyfile"
  exit 1
fi

echo "Starting Caddy..."
docker run -d --name caddy --network $NETWORK_NAME \
  -p 80:80 -p 443:443 \
  -e HUB_HOST="${HUB_HOST}" \
  -v "$BASE_DIR/Caddyfile:/etc/caddy/Caddyfile:ro" \
  -v "$CADDY_DATA_DIR/data:/data" \
  -v "$CADDY_DATA_DIR/config:/config" \
  --restart unless-stopped \
  --platform linux/amd64 \
  caddy:2-alpine

echo "Cleaning up temp artifacts..."
rm -f "$BASE_DIR/rivet-images.tar.gz"
rm -f "$BASE_DIR/Caddyfile"

echo "Done"
