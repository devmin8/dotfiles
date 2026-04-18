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
  scp -r ./dotfiles/. "${PAAS_SERVER}:~/dotfiles"
}