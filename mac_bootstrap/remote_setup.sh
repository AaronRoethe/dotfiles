#!/bin/zsh
# Fresh-Mac entry point: Xcode CLI tools, dotfiles checkout, then bootstrap.sh.
# Usage: /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/AaronRoethe/dotfiles/master/mac_bootstrap/remote_setup.sh)"
set -euo pipefail

if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    echo "Waiting for Xcode Command Line Tools to finish installing..."
    until xcode-select -p &>/dev/null; do sleep 10; done
fi

config() { /usr/bin/git --git-dir="$HOME/.cfg" --work-tree="$HOME" "$@"; }

if [[ ! -d "$HOME/.cfg" ]]; then
    git clone --bare https://github.com/AaronRoethe/dotfiles.git "$HOME/.cfg"
    config config --local status.showUntrackedFiles no
    config checkout || { echo "Checkout failed: move the conflicting files above out of \$HOME and re-run."; exit 1; }
fi

zsh "$HOME/mac_bootstrap/bootstrap.sh"
