ps_cp() {
  local src="$1"
  local dest="$2"

  if [[ -z "$src" || -z "$dest" ]]; then
    echo "Usage: ps_cp <source> <destination_path_on_remote>"
    return 1
  fi

  if [[ -d "$src" ]]; then
    scp -r "$src" "${PAAS_SERVER}:$dest"
  else
    scp "$src" "${PAAS_SERVER}:$dest"
  fi
}

ps_push_dotfiles() {
  ssh "$PAAS_SERVER" "mkdir -p ~/dotfiles"
  scp -r ./dotfiles-vps/. "${PAAS_SERVER}:~/dotfiles"
}

rivet_cli_mac_build() {
  echo "👉 Building Go CLI (macOS Apple Silicon)..."
  GOOS=darwin GOARCH=arm64 CGO_ENABLED=0 \
    go build -o rivet ./cmd/cli/main.go

  mv rivet ~/Binaries/

  echo "✅ Built and moved to ~/Binaries"
}

rivet_build() {
  echo "👉 Building Go CLI (linux/amd64)..."
  GOOS=linux GOARCH=amd64 CGO_ENABLED=0 \
    go build -o rivet-linux-amd64 ./cmd/cli/main.go

  rivet_cli_mac_build

  echo "👉 Building images (amd64)..."
  docker buildx build --platform linux/amd64 \
    --build-arg TARGET=hub \
    -t rivet-hub:latest . --load

  echo "👉 Pulling Caddy..."
  docker pull caddy:2-alpine

  echo "👉 Saving images..."
  docker save rivet-hub:latest caddy:2-alpine | gzip > rivet-images.tar.gz

  echo "👉 Uploading to server..."
  ssh $PAAS_SERVER "mkdir -p ~/rivet"
  scp rivet-images.tar.gz Caddyfile rivet-linux-amd64 "$PAAS_SERVER:~/rivet/"

  rm -rf rivet-images.tar.gz

  echo "Done 🚀"
}

rivet_run() {
  HUB_HOST=http://hub.localhost \
  docker compose up --build
}

clean_docker_images() {
  docker rm -f $(docker ps -aq)
  docker system prune -a --volumes -f
}

# cli commands
signup() {
  rivet signup --email shan@mail.com --username shan
}

login() {
  rivet login --username shan
}

push() {
  rivet push --tag static
}

ship() {
  rivet ship
}
