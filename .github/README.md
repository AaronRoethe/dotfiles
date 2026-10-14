# Dotfiles

macOS dotfiles managed as a bare git repo in `~/.cfg`, with `$HOME` as the work tree. Built for [Warp](https://www.warp.dev/), so there's no zsh framework or prompt theme.

## Setup

Fresh Mac:

1. Download `mac_bootstrap/remote_setup.sh` from this repo. It's private, so use the GitHub web UI. Unauthenticated raw URLs won't work.
2. Run it with this repo's clone URL (or your fork's):
   ```bash
   DOTFILES_REPO=https://github.com/<owner>/<repo>.git zsh ~/Downloads/remote_setup.sh
   ```
   Git prompts for credentials during the clone. Use a GitHub personal access token as the password.

This installs the Xcode CLI tools, checks the dotfiles out into `$HOME`, and runs `mac_bootstrap/bootstrap.sh`. That script creates your profile (see below), then installs Homebrew, everything in [`mac_bootstrap/Brewfile`](../mac_bootstrap/Brewfile), Python (pyenv) and Node LTS (nvm). It's safe to re-run.

## Profile

Nothing tracked is tied to one person. Personal values live in `~/.env/profile.sh`, which is never committed:

| Variable | Used for |
| --- | --- |
| `PROFILE_NAME` | git `user.name` |
| `PROFILE_GH_USER` | personal GitHub account: dotfiles fork, git URL rewrite to the `github-personal` SSH host |
| `PROFILE_WORK_USER` | work username, also the git branch prefix |
| `PROFILE_WORK_EMAIL` | work email |
| `PROFILE_SLACK_USER_ID` | your own Slack DM (Claude Code can send there directly; everything else is a draft) |
| `PROFILE_JIRA_ACCOUNT_ID` | Jira assignee when Claude Code creates tickets for you |

On the first run, `bootstrap.sh` copies the template `~/.env/profile.sh.example` to `~/.env/profile.sh` and stops. Fill it in and re-run. The bootstrap then writes your git identity to `~/.gitconfig.local`.

The profile is read by:
- `.zshrc`, which loads every `~/.env/*.sh`, so it's exported in every shell
- `bootstrap.sh`, to generate `~/.gitconfig.local`
- Claude Code, through the `@~/.env/profile.sh` import in `~/.claude/CLAUDE.md`
- the Claude Code hooks and the launchd standup job, which `source` it directly

To add a value, put it in both `profile.sh` and `profile.sh.example`, and refer to it by name instead of hardcoding it.

## Layout

```
.zshrc                      sources every ~/.env/*.sh
.zprofile                   Homebrew + pyenv init
.env/exports.sh             PATH and runtimes
.env/git.sh                 git helpers
.env/python.sh              venv helpers
.env/shell.sh               general aliases
.env/profile.sh.example     template for the local-only profile (see Profile)
.gitconfig                  git settings and aliases (identity comes from untracked includes)
.gitignore                  local-only files the dotfiles repo must never commit
.ssh/config                 SSH hosts
.claude/                    Claude Code config (see ~/.claude/README.md)
mac_bootstrap/
  remote_setup.sh           fresh-Mac entry point
  bootstrap.sh              Homebrew, Brewfile, runtimes
  Brewfile                  packages and apps
  config-rectangle.json     Rectangle config (import manually in Rectangle > Settings)
  config.code-workspace     VS Code workspace for mac_bootstrap/ and .env/
  test/                     Docker test of the new-user setup (see Testing)
```

## Local-only files

These are loaded if present but never committed (listed in the tracked `~/.gitignore`, so the list comes with every clone):

| File | Loaded by |
| --- | --- |
| `~/.env/profile.sh` | `.zshrc`, `bootstrap.sh`, Claude Code (personal values, see Profile) |
| `~/.env/local.sh` | `.zshrc` (credentials, personal helpers) |
| `~/.env/work.sh` | `.zshrc` (work helpers) |
| `~/.gitconfig.local` | `.gitconfig` `[include]` (name, personal URL rewrite; generated from the profile) |
| `~/.gitconfig.work` | `.gitconfig` `[include]` (work email, host rewrites) |
| `mac_bootstrap/Brewfile.work` | `bootstrap.sh` (work-only taps and apps) |

## Claude Code config

Global Claude Code config in `~/.claude` is tracked here: `CLAUDE.md`, settings and hooks, agents, skills, and reference files. Claude Code writes a lot of other state into `~/.claude` (sessions, memory, plugin code), so `~/.claude/.gitignore` whitelists only those files. Personal values come from the profile. Most of it is work-specific, which is why this repo must stay private.

The setup above restores it. Plugins reinstall from the marketplaces in `settings.json`, and MCP tokens are added by hand. `~/.claude/README.md` covers the details, the hooks, and how to manage it.

## Testing the new-user setup

`mac_bootstrap/test/` simulates a new user's first setup in a clean Docker container (Debian, non-root user) and checks the result:

```bash
zsh ~/mac_bootstrap/test/run.sh
```

It tests the dotfiles as they'd be cloned: the committed `HEAD` plus any tracked or staged changes. Untracked files aren't included, so `config add` new files first. The steps follow this README:

1. Download `remote_setup.sh` and run it without, then with, `DOTFILES_REPO`. Checks the clone, the checkout, and that the first run creates the profile and stops.
2. Fill in a test profile and re-run `bootstrap.sh`. Checks the Homebrew install, a real `brew bundle` of one formula (`test/Brewfile.test`), the runtime steps, and that it's safe to re-run.
3. Checks the git identity, `.zshrc` loading the profile, local-only files being ignored, and a clean `config status`. Also checks that none of **your** profile values appear in any tracked file.
4. Checks that the Claude Code config loads the profile, and that the hooks work for the new user: Slack own-DM vs other channels, `sudo`, force-push, the gitleaks commit block, and the push identity check.

macOS-only or slow steps are stubbed and logged to `~/stub.log` in the container: `xcode-select`, `pyenv` (no Python compile) and `nvm` (no Node download). Homebrew itself is installed for real, at its Linux prefix, so a run takes a few minutes.

## Managing

```bash
config status
config add -u
config commit -m "..."
config push
```
