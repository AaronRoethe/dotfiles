#!/bin/zsh
# Fresh-Mac entry point: Xcode CLI tools, dotfiles checkout, then bootstrap.sh.
# Usage (see ~/.github/README.md): clone the bare repo to ~/.cfg over SSH, then run this from it:
#   git clone --bare git@github.com:<org>/<repo>.git ~/.cfg
#   zsh <(git --git-dir="$HOME/.cfg" show HEAD:mac_bootstrap/remote_setup.sh)
# Without an existing ~/.cfg it clones DOTFILES_REPO itself. Safe to re-run.
set -euo pipefail

if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    echo "Waiting for Xcode Command Line Tools to finish installing..."
    until xcode-select -p &>/dev/null; do sleep 10; done
fi

config() { /usr/bin/git --git-dir="$HOME/.cfg" --work-tree="$HOME" "$@"; }

if [[ ! -d "$HOME/.cfg" ]]; then
    : "${DOTFILES_REPO:?~/.cfg not found. Clone it first (see README), or set DOTFILES_REPO to the clone URL}"
    git clone --bare "$DOTFILES_REPO" "$HOME/.cfg"
fi
config config --local status.showUntrackedFiles no
config checkout || { echo "Checkout failed: move the conflicting files above out of \$HOME and re-run."; exit 1; }

zsh "$HOME/mac_bootstrap/bootstrap.sh"
