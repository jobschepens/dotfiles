#!/usr/bin/env bash
# Link the shell files in this repository into $HOME and install oh-my-zsh.
# No sudo, no package installation, no SSH or VS Code edits.
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

backup() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.backup"
    echo "Backed up $target -> $target.backup"
  fi
}

link() {
  local name="$1" target="$HOME/.$1"
  backup "$target"
  ln -sfn "$repo_dir/$name" "$target"
  echo "Linked $target -> $repo_dir/$name"
}

command -v zsh >/dev/null 2>&1 || {
  echo "zsh is not installed. Install it with your package manager, then rerun this script." >&2
  exit 1
}

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to install oh-my-zsh." >&2
    exit 1
  fi
  echo "Installing oh-my-zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# These plugins are bundled with current oh-my-zsh; clone only for older setups.
zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  if [ ! -d "$HOME/.oh-my-zsh/plugins/$plugin" ] && [ ! -d "$zsh_custom/plugins/$plugin" ]; then
    echo "Installing oh-my-zsh plugin $plugin..."
    mkdir -p "$zsh_custom/plugins"
    git clone --depth=1 "https://github.com/zsh-users/$plugin" "$zsh_custom/plugins/$plugin"
  fi
done

for name in zshrc zprofile aliases; do
  link "$name"
done

echo
echo "Done. Run 'exec zsh' or open a new terminal."
