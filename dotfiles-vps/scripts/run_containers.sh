HUB_HOST="hub.getrivet.app"
SAMPLE_API_HOST="sample-api.getrivet.app"
HUB_SERVER_PORT=8080
SAMPLE_SERVER_PORT=3000

BASE_DIR="$HOME/rivet"

echo "Ensuring base directory..."
mkdir -p "$BASE_DIR"

echo "Loading Docker images..."
gunzip -c "$BASE_DIR/rivet-images.tar.gz" | docker load

echo "Creating network if not exists..."
docker network inspect rivet-net >/dev/null 2>&1 || docker network create rivet-net

echo "Stopping old containers if they exist..."
docker rm -f hub sampleapi caddy >/dev/null 2>&1 || true

echo "Starting hub..."
docker run -d --name hub --network rivet-net \
  -e HUB_SERVER_PORT=${HUB_SERVER_PORT} \
  --restart unless-stopped \
  rivet-hub:latest

echo "Starting sample API..."
docker run -d --name sampleapi --network rivet-net \
  -e SAMPLE_SERVER_PORT=${SAMPLE_SERVER_PORT} \
  --restart unless-stopped \
  rivet-sampleapi:latest

echo "Checking Caddyfile..."
if [ ! -f "$BASE_DIR/Caddyfile" ]; then
  echo "❌ Caddyfile not found at $BASE_DIR/Caddyfile"
  exit 1
fi

echo "Starting Caddy..."
docker run -d --name caddy --network rivet-net \
  -p 80:80 -p 443:443 \
  -e HUB_HOST=${HUB_HOST} \
  -e SAMPLE_API_HOST=${SAMPLE_API_HOST} \
  -v "$BASE_DIR/Caddyfile:/etc/caddy/Caddyfile:ro" \
  --restart unless-stopped \
  --platform linux/amd64 \
  caddy:2-alpine

echo "Cleaning up temp artifacts..."
rm -f "$BASE_DIR/rivet-images.tar.gz"
rm -f "$BASE_DIR/Caddyfile"

echo "Done 🚀"
