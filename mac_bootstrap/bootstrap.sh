#!/bin/zsh
# Installs Homebrew, everything in the Brewfile(s), and language runtimes.
# Safe to re-run. Usage: zsh ~/mac_bootstrap/bootstrap.sh
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

brew bundle --file=Brewfile
[[ -f Brewfile.work ]] && brew bundle --file=Brewfile.work

pyenv install --skip-existing 3.13
[[ "$(pyenv global)" == system ]] && pyenv global "$(pyenv latest 3.13)"

export NVM_DIR="$HOME/.nvm"
[[ -d "$NVM_DIR" ]] || curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | PROFILE=/dev/null bash
source "$NVM_DIR/nvm.sh"
nvm install --lts

mkdir -p "$HOME/repos/go"

echo "Done. Open a new Warp tab to load the shell config."
