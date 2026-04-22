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

rivet_build() {
  echo "Building images (amd64)..."
  docker buildx build --platform linux/amd64 --build-arg TARGET=hub -t rivet-hub:latest . --load

  echo "Pulling Caddy..."
  docker pull caddy:2-alpine

  echo "Saving images..."
  docker save rivet-hub:latest caddy:2-alpine | gzip > rivet-images.tar.gz

  echo "Uploading to server..."
  ssh $PAAS_SERVER "mkdir -p ~/rivet"
  scp rivet-images.tar.gz Caddyfile "$PAAS_SERVER:~/rivet/"

  rm -rf rivet-images.tar.gz

  echo "Done 🚀"
}
