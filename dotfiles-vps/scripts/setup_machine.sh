#!/usr/bin/env bash

# Fail fast:
# -e  exit on any error
# -u  error on undefined variables
# -o pipefail  fail if any command in a pipeline fails
set -euo pipefail

echo "⚙️  Setting up machine..."

# set default shell to zsh
if [[ "$SHELL" != "$(which zsh)" ]]; then
  echo "→ Setting zsh as default shell..."
  chsh -s "$(which zsh)"
else
  echo "✓ zsh already default shell"
fi

# Docker (only if missing)
if ! command -v docker >/dev/null 2>&1; then
  echo "→ Installing Docker..."

  sudo apt update
  sudo apt install -y ca-certificates curl

  sudo install -m 0755 -d /etc/apt/keyrings

  if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg \
      -o /etc/apt/keyrings/docker.asc
  fi

  sudo chmod a+r /etc/apt/keyrings/docker.asc

  if [[ ! -f /etc/apt/sources.list.d/docker.sources ]]; then
    sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
  fi

  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  sudo systemctl enable docker
  sudo systemctl start docker

  echo "→ Running hello-world test..."
  sudo docker run --rm hello-world

else
  echo "✓ Docker already installed"
fi

# Docker without sudo (optional but standard)
if command -v docker >/dev/null 2>&1; then
  if ! groups "$USER" | grep -q docker; then
    echo "→ Adding user to docker group..."
    sudo usermod -aG docker "$USER"
    echo "⚠️  Log out and back in to apply docker group"
  else
    echo "✓ User already in docker group"
  fi
fi

# Install rsync (if missing)
if ! command -v rsync >/dev/null 2>&1; then
  echo "→ Installing rsync..."
  sudo apt update -y
  sudo apt install -y rsync
else
  echo "✓ rsync already installed"
fi

echo "\n✅ Setup complete"
echo "🔄 Refresh the shell"
