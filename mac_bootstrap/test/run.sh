#!/bin/zsh
# Simulates a new user's first setup in a clean Docker container and checks the result.
# Usage: zsh ~/mac_bootstrap/test/run.sh
# Tests committed HEAD of ~/.cfg, which is what a new user clones; commit first, no need to push.
# Read-only on the host: ~/.cfg is mounted read-only and the container clones from it.
set -euo pipefail
here=${0:A:h}

echo "Testing committed HEAD $(git --git-dir="$HOME/.cfg" rev-parse --short HEAD) of ~/.cfg"
docker build -q -t dotfiles-e2e "$here" >/dev/null

# Your own profile values must not show up in any tracked file; the container checks for them.
source "$HOME/.env/profile.sh"
owner_values=$(print -l -- "$PROFILE_NAME" "$PROFILE_GH_USER" "$PROFILE_WORK_USER" "$PROFILE_WORK_EMAIL" "$PROFILE_SLACK_USER_ID" "$PROFILE_JIRA_ACCOUNT_ID")
docker run --rm -v "$HOME/.cfg:/dotfiles.git:ro" -e OWNER_VALUES="$owner_values" dotfiles-e2e
