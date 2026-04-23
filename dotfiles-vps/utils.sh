alias cls="clear"
alias dl="rm -rf"

# git related
alias gc="git checkout"
alias gcb="git checkout -b"
alias gcm="git commit -m"
alias gss="git stash save"
alias gp="git push"
alias gpf="git push --force-with-lease"
alias ga="git add ."
alias gl="git log"

# tools
alias b="bun"

alias d="docker"
alias dc="docker_clean"

# util functions
docker_clean() {
  docker rm -f $(docker ps -aq)
  docker system prune -a --volumes -f
}

clean() {
  docker_clean
  rm -f "$BASE_DIR/rivet-images.tar.gz"
  rm -f "$BASE_DIR/Caddyfile"
  rm -rf "$HOME/.config/rivet"
}

setup_machine() {
  local script="$HOME/dotfiles/scripts/setup_machine.sh"

  if [[ ! -f "$script" ]]; then
    echo "setup_machine.sh not found at $script"
    return 1
  fi

  bash "$script"
}

run_containers() {
  local script="$HOME/dotfiles/scripts/run_containers.sh"

  if [[ ! -f "$script" ]]; then
    echo "run_containers.sh not found at $script"
    return 1
  fi

  bash "$script"
}

rerun_hub() {
  local script="$HOME/dotfiles/scripts/rerun_hub.sh"

  if [[ ! -f "$script" ]]; then
    echo "rerun_hub.sh not found at $script"
    return 1
  fi

  bash "$script"
}
