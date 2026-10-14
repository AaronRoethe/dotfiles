#!/bin/zsh
# Runs inside the Docker image: follows the README's new-user setup and checks the results.
# Expects the dotfiles repo (bare) mounted at /dotfiles.git, and OWNER_VALUES: newline-separated personal
# values of whoever ran the test (from their profile), which must not appear in tracked files.
# Driven by mac_bootstrap/test/run.sh.
setopt no_err_exit
pass=0 fail=0
ok()   { print -P "%F{green}PASS%f $1"; (( ++pass )); return 0; }
bad()  { print -P "%F{red}FAIL%f $1"; [[ -n "$2" ]] && print -- "$2" | sed 's/^/     /'; (( ++fail )); return 0; }
check() { local name=$1; shift; if "$@" >/dev/null 2>&1; then ok "$name"; else bad "$name"; fi; }
step() { print -P "\n%F{blue}== $1%f"; }
config() { git --git-dir="$HOME/.cfg" --work-tree="$HOME" "$@"; }
hook() { local out; out=$(jq -nc "$2" | "$HOME/.claude/hooks/$1"); [[ -z $out ]] && echo allow || jq -r '.hookSpecificOutput.permissionDecision' <<<"$out"; }
owner_leaks() { [[ -n ${OWNER_VALUES:-} ]] && grep -lF -f <(print -r -- "$OWNER_VALUES") "$@" 2>/dev/null; }

# Stub for nvm (its real install downloads Node). bootstrap.sh skips the nvm installer when ~/.nvm exists.
mkdir -p ~/.nvm && print 'nvm() { echo "nvm $*" >> "$HOME/stub.log"; }' > ~/.nvm/nvm.sh

step "1. Install Homebrew, then git from Homebrew (README: Setup step 1)"
out=$(/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>&1); rc=$?
[[ $rc -eq 0 ]] && ok "Homebrew installer runs" || bad "Homebrew installer runs (rc=$rc)" "$(print -- "$out" | tail -10)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"   # README uses /opt/homebrew, the macOS prefix
out=$(brew install git 2>&1); rc=$?
[[ $rc -eq 0 ]] && ok "brew install git" || bad "brew install git (rc=$rc)" "$(print -- "$out" | tail -10)"
[[ $(command -v git) == /home/linuxbrew/* ]] && ok "git on PATH is Homebrew's" || bad "git on PATH is Homebrew's: $(command -v git)"

step "2. Clone the dotfiles and run remote_setup.sh from the clone (README: Setup step 2)"
out=$(env -u DOTFILES_REPO zsh <(git --git-dir=/dotfiles.git show HEAD:mac_bootstrap/remote_setup.sh) 2>&1)
[[ $out == *"~/.cfg not found"* && ! -d ~/.cfg ]] && ok "remote_setup.sh without ~/.cfg or DOTFILES_REPO stops with a hint" || bad "remote_setup.sh without ~/.cfg or DOTFILES_REPO" "$out"
# The README clones over SSH; the container has no SSH, so a local file:// clone stands in for it.
out=$(git clone --bare file:///dotfiles.git ~/.cfg 2>&1)
[[ -d ~/.cfg ]] && ok "bare repo cloned to ~/.cfg" || bad "bare repo cloned to ~/.cfg" "$out"
# README's last command, verbatim
out=$(zsh <(git --git-dir="$HOME/.cfg" show HEAD:mac_bootstrap/remote_setup.sh) 2>&1); rc=$?
[[ -f ~/.zshrc && -f ~/.claude/CLAUDE.md && -f ~/mac_bootstrap/bootstrap.sh ]] && ok "dotfiles checked out into \$HOME" || bad "dotfiles checked out into \$HOME" "$out"
[[ $rc -ne 0 && $out == *"Created ~/.env/profile.sh"* ]] && ok "first run creates the profile and stops" || bad "first run creates the profile and stops (rc=$rc)" "$out"
check "profile.sh is a copy of the template" cmp ~/.env/profile.sh ~/.env/profile.sh.example
[[ $(config config status.showUntrackedFiles) == no ]] && ok "status.showUntrackedFiles is off" || bad "status.showUntrackedFiles is off"

step "3. Fill in the profile and re-run bootstrap.sh (README: Profile)"
cat > ~/.env/profile.sh <<'EOF'
export PROFILE_NAME="Test User"
export PROFILE_GH_USER=testuser-gh
export PROFILE_WORK_USER=tuser
export PROFILE_WORK_EMAIL=tuser@axon.com
export PROFILE_SLACK_USER_ID=U0TESTUSER
export PROFILE_JIRA_ACCOUNT_ID=000000000000000000000001
EOF
out=$(BREWFILE=test/Brewfile.test zsh ~/mac_bootstrap/bootstrap.sh 2>&1); rc=$?
[[ $rc -eq 0 ]] && ok "bootstrap.sh completes" || bad "bootstrap.sh completes (rc=$rc)" "$(print -- "$out" | tail -15)"
[[ $(hello 2>/dev/null) == "Hello, world!" ]] && ok "brew bundle installed the test formula (hello)" || bad "brew bundle installed the test formula (hello)"
grep -q "pyenv install --skip-existing 3.13" ~/stub.log && ok "pyenv runtime step ran (stubbed)" || bad "pyenv runtime step ran (stubbed)"
grep -q "nvm install --lts" ~/stub.log && ok "nvm runtime step ran (stubbed)" || bad "nvm runtime step ran (stubbed)"
check "bootstrap.sh is safe to re-run" env BREWFILE=test/Brewfile.test zsh ~/mac_bootstrap/bootstrap.sh

step "4. Git identity comes from the profile"
[[ $(git config user.name) == "Test User" ]] && ok "user.name from profile" || bad "user.name from profile: '$(git config user.name)'"
[[ $(git config user.email) == "tuser@axon.com" ]] && ok "user.email from profile" || bad "user.email from profile: '$(git config user.email)'"
[[ $(git config url.git@github-personal:testuser-gh/.insteadOf) == "https://github.com/testuser-gh/" ]] && ok "personal URL rewrite from profile" || bad "personal URL rewrite from profile"
config config --list --show-origin | owner_leaks /dev/stdin >/dev/null && bad "no previous owner's identity in tracked git config" || ok "no previous owner's identity in tracked git config"

step "5. Shell loads the profile"
[[ $(zsh -i -c 'print -r -- $PROFILE_WORK_USER' 2>/dev/null) == tuser ]] && ok ".zshrc exports PROFILE_* variables" || bad ".zshrc exports PROFILE_* variables"

step "6. Local-only files stay out of the repo"
for f in .env/profile.sh .gitconfig.local; do
    config check-ignore -q "$f" && ok "$f is ignored" || bad "$f is ignored"
done
[[ -z $(config status --porcelain) ]] && ok "config status is clean after setup" || bad "config status is clean after setup" "$(config status --porcelain)"
[[ -n ${OWNER_VALUES:-} ]] || bad "OWNER_VALUES passed in by run.sh"
tracked=(${(0)"$(cd ~ && config ls-files -z)"}); leaks=$(cd ~ && owner_leaks $tracked)
[[ -z $leaks ]] && ok "no previous owner's personal values in tracked files" || bad "no previous owner's personal values in tracked files" "$leaks"

step "7. Claude Code config"
grep -qx '@~/.env/profile.sh' ~/.claude/CLAUDE.md && ok "CLAUDE.md imports the profile" || bad "CLAUDE.md imports the profile"
check "settings.json is valid JSON with hooks" jq -e '.hooks.PreToolUse and .hooks.PostToolUse' ~/.claude/settings.json
for h in ~/.claude/hooks/*.sh; do [[ -x $h ]] && ok "hook executable: ${h:t}" || bad "hook executable: ${h:t}"; done
[[ -f ~/.claude/mcp-servers.template.json ]] && ! grep -q 'Bearer\|ghp_' ~/.claude/mcp-servers.template.json && ok "MCP template present and redacted" || bad "MCP template present and redacted"

step "8. Claude Code hooks behave for the new user"
[[ $(hook guard-slack-send.sh '{"tool_name":"mcp__claude_ai_Slack__slack_send_message","tool_input":{"channel_id":"U0TESTUSER"}}') == allow ]] && ok "Slack: send to own DM (profile ID) allowed" || bad "Slack: send to own DM (profile ID) allowed"
[[ $(hook guard-slack-send.sh '{"tool_name":"mcp__claude_ai_Slack__slack_send_message","tool_input":{"channel_id":"C0OTHER"}}') == deny ]] && ok "Slack: send to another channel denied" || bad "Slack: send to another channel denied"
[[ $(hook guard-bash.sh '{tool_input:{command:"sudo ls"},cwd:"/tmp"}') == deny ]] && ok "Bash: sudo denied" || bad "Bash: sudo denied"
[[ $(hook guard-bash.sh '{tool_input:{command:"git push --force origin main"},cwd:"/tmp"}') == deny ]] && ok "Bash: force-push to main denied" || bad "Bash: force-push to main denied"
repo=$(mktemp -d) && git -C $repo init -q && git -C $repo remote add origin git@github.com:axon-productivity/example.git
print "token = ghp_$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 36)" > $repo/leak.env && git -C $repo add leak.env
[[ $(hook guard-bash.sh "{tool_input:{command:\"git commit -m x\"},cwd:\"$repo\"}") == deny ]] && ok "Bash: commit with a secret blocked by gitleaks" || bad "Bash: commit with a secret blocked by gitleaks"
git -C $repo rm -q --cached leak.env && print hi > $repo/ok.txt && git -C $repo add ok.txt
[[ $(hook guard-bash.sh "{tool_input:{command:\"git commit -m x\"},cwd:\"$repo\"}") == allow ]] && ok "Bash: clean commit allowed" || bad "Bash: clean commit allowed"
[[ $(hook guard-bash.sh "{tool_input:{command:\"git push\"},cwd:\"$repo\"}") == ask ]] && ok "Bash: push to work remote asks for confirmation" || bad "Bash: push to work remote asks for confirmation"
git -C $repo config user.email someone@gmail.com
[[ $(hook guard-bash.sh "{tool_input:{command:\"git push\"},cwd:\"$repo\"}") == deny ]] && ok "Bash: push to work remote with non-work email denied" || bad "Bash: push to work remote with non-work email denied"

print -P "\n%B$pass passed, $fail failed%b"
(( fail == 0 ))
