HUB_HOST="hub.getrivet.app"
HUB_SERVER_PORT=8080
HUB_DB_PATH="/var/lib/rivet/hub.db"

BASE_DIR="$HOME/rivet"
DATA_DIR="$BASE_DIR/data"

echo "Ensuring base directory..."
mkdir -p "$BASE_DIR" "$DATA_DIR"

echo "Ensuring hub data directory is writable..."
sudo chown -R 65532:65532 "$DATA_DIR"

echo "Loading Docker images..."
gunzip -c "$BASE_DIR/rivet-images.tar.gz" | docker load

echo "Creating network if not exists..."
docker network inspect rivet-net >/dev/null 2>&1 || docker network create rivet-net

echo "Stopping old containers if they exist..."
docker rm -f hub caddy >/dev/null 2>&1 || true

echo "Starting hub..."
docker run -d --name hub --network rivet-net \
  -e HUB_SERVER_PORT="${HUB_SERVER_PORT}" \
  -e HUB_DB_PATH="${HUB_DB_PATH}" \
  -v "$DATA_DIR:/var/lib/rivet" \
  --restart unless-stopped \
  rivet-hub:latest

echo "Checking Caddyfile..."
if [ ! -f "$BASE_DIR/Caddyfile" ]; then
  echo "Caddyfile not found at $BASE_DIR/Caddyfile"
  exit 1
fi

echo "Starting Caddy..."
docker run -d --name caddy --network rivet-net \
  -p 80:80 -p 443:443 \
  -e HUB_HOST="${HUB_HOST}" \
  -v "$BASE_DIR/Caddyfile:/etc/caddy/Caddyfile:ro" \
  --restart unless-stopped \
  --platform linux/amd64 \
  caddy:2-alpine

echo "Cleaning up temp artifacts..."
rm -f "$BASE_DIR/rivet-images.tar.gz"
rm -f "$BASE_DIR/Caddyfile"

echo "Done"
