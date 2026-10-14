#!/bin/zsh
# Simulates a new user's first setup in a clean Docker container and checks the result.
# Usage: zsh ~/mac_bootstrap/test/run.sh
# Tests the dotfiles as they'd be cloned: committed HEAD plus any tracked or staged changes
# (untracked files aren't included, so `config add` new files first).
set -euo pipefail
here=${0:A:h}
cfg() { /usr/bin/git --git-dir="$HOME/.cfg" --work-tree="$HOME" "$@"; }

snapshot=$(cfg stash create)          # commit of the working state; empty if nothing changed
snapshot=${snapshot:-$(cfg rev-parse HEAD)}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git init -q --bare "$tmp/dotfiles.git"
cfg update-ref refs/e2e/snapshot "$snapshot"
git --git-dir="$tmp/dotfiles.git" fetch -q "$HOME/.cfg" refs/e2e/snapshot:refs/heads/master
cfg update-ref -d refs/e2e/snapshot
git --git-dir="$tmp/dotfiles.git" symbolic-ref HEAD refs/heads/master
echo "Testing snapshot ${snapshot:0:7} of ~/.cfg"

docker build -q -t dotfiles-e2e "$here" >/dev/null
# Your own profile values must not show up in any tracked file; the container checks for them.
source "$HOME/.env/profile.sh"
owner_values=$(print -l -- "$PROFILE_NAME" "$PROFILE_GH_USER" "$PROFILE_WORK_USER" "$PROFILE_WORK_EMAIL" "$PROFILE_SLACK_USER_ID" "$PROFILE_JIRA_ACCOUNT_ID")
docker run --rm -v "$tmp/dotfiles.git:/dotfiles.git:ro" -e OWNER_VALUES="$owner_values" dotfiles-e2e
