#!/bin/zsh
# Fresh-Mac entry point: Xcode CLI tools, dotfiles checkout, then bootstrap.sh.
# Usage: DOTFILES_REPO=<clone URL of the dotfiles repo> zsh remote_setup.sh
set -euo pipefail
: "${DOTFILES_REPO:?Set DOTFILES_REPO to the dotfiles repo clone URL, e.g. https://github.com/<owner>/<repo>.git}"

if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    echo "Waiting for Xcode Command Line Tools to finish installing..."
    until xcode-select -p &>/dev/null; do sleep 10; done
fi

config() { /usr/bin/git --git-dir="$HOME/.cfg" --work-tree="$HOME" "$@"; }

if [[ ! -d "$HOME/.cfg" ]]; then
    git clone --bare "$DOTFILES_REPO" "$HOME/.cfg"
    config config --local status.showUntrackedFiles no
    config checkout || { echo "Checkout failed: move the conflicting files above out of \$HOME and re-run."; exit 1; }
fi

zsh "$HOME/mac_bootstrap/bootstrap.sh"
