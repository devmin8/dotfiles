#!/usr/bin/env bash

# Fail fast:
# -e  exit on any error
# -u  error on undefined variables
# -o pipefail  fail if any command in a pipeline fails
set -euo pipefail

echo "Setting up environment...\n"

# install git
if ! command -v git &> /dev/null; then
  sudo apt update && sudo apt install -y git
fi

# install zsh shell
if ! command -v zsh >/dev/null 2>&1; then
  echo "→ Installing zsh..."
  sudo apt update -y
  sudo apt install -y zsh
else
  echo "✓ zsh already installed"
fi

# install oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "→ Installing oh-my-zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "✓ oh-my-zsh already installed"
fi

# dotfiles
echo "→ Linking dotfiles..."
rm -rf ~/.zshrc
ln -sf ~/dotfiles/.zshrc ~/.zshrc
echo "✓ dotfiles linked"

echo "\n✅ Environment setup done."
echo "🔄 Refresh the shell"

echo "👉 Run the 'setup_machine' command to install necessary tools\n"
