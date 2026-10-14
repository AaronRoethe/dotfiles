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

## Managing

```bash
config status
config add -u
config commit -m "..."
config push
```
