#!/bin/zsh
# Installs Homebrew, everything in the Brewfile(s), and language runtimes.
# Safe to re-run. Usage: zsh ~/mac_bootstrap/bootstrap.sh
set -euo pipefail
cd "$(dirname "$0")"

# Personal profile: create from the template on first run, then generate the git identity from it.
if [[ ! -f "$HOME/.env/profile.sh" ]]; then
    cp "$HOME/.env/profile.sh.example" "$HOME/.env/profile.sh"
    echo "Created ~/.env/profile.sh. Fill in your values, then re-run: zsh ~/mac_bootstrap/bootstrap.sh"
    exit 1
fi
source "$HOME/.env/profile.sh"
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
    cat > "$HOME/.gitconfig.local" <<EOF
# Local-only: personal identity, generated from ~/.env/profile.sh by mac_bootstrap/bootstrap.sh.
[user]
    name = $PROFILE_NAME
    email = $PROFILE_WORK_EMAIL

[url "git@github-personal:$PROFILE_GH_USER/"]
	insteadOf = https://github.com/$PROFILE_GH_USER/
EOF
fi

if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# /opt/homebrew on Apple Silicon; the Linux path is only used by the Docker test (mac_bootstrap/test).
for brew_bin in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [[ -x "$brew_bin" ]] && eval "$("$brew_bin" shellenv)" && break
done

# BREWFILE lets the Docker test swap in a one-formula Brewfile.
brew bundle --file="${BREWFILE:-Brewfile}"
[[ -z "${BREWFILE:-}" && -f Brewfile.work ]] && brew bundle --file=Brewfile.work

pyenv install --skip-existing 3.13
[[ "$(pyenv global)" == system ]] && pyenv global "$(pyenv latest 3.13)"

export NVM_DIR="$HOME/.nvm"
[[ -d "$NVM_DIR" ]] || curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | PROFILE=/dev/null bash
source "$NVM_DIR/nvm.sh"
nvm install --lts

mkdir -p "$HOME/repos/go"

echo "Done. Open a new Warp tab to load the shell config."
