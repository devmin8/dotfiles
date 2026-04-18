alias cls="clear"

# util functions
setup_machine() {
  local script="$HOME/dotfiles/scripts/setup_machine.sh"

  if [[ ! -f "$script" ]]; then
    echo "setup_machine.sh not found at $script"
    return 1
  fi

  bash "$script"
}
