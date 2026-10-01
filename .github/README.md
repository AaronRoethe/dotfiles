# Aaron's Dotfiles

macOS dotfiles managed as a bare git repo in `~/.cfg`, with `$HOME` as the work tree. Built for [Warp](https://www.warp.dev/), so there's no zsh framework or prompt theme.

## Setup

Fresh Mac:

```bash
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/AaronRoethe/dotfiles/master/mac_bootstrap/remote_setup.sh)"
```

This installs the Xcode CLI tools, checks the dotfiles out into `$HOME`, and runs `mac_bootstrap/bootstrap.sh`. That script installs Homebrew, everything in [`mac_bootstrap/Brewfile`](../mac_bootstrap/Brewfile), Python (pyenv) and Node LTS (nvm). It's safe to re-run.

## Layout

```
.zshrc                      sources every ~/.env/*.sh
.zprofile                   Homebrew + pyenv init
.env/exports.sh             PATH and runtimes
.env/git.sh                 git helpers
.env/python.sh              venv helpers
.env/shell.sh               general aliases
.gitconfig                  git settings and aliases
.ssh/config                 SSH hosts
mac_bootstrap/
  remote_setup.sh           fresh-Mac entry point
  bootstrap.sh              Homebrew, Brewfile, runtimes
  Brewfile                  packages and apps
  config-rectangle.json     Rectangle config (import manually in Rectangle > Settings)
  config.code-workspace     VS Code workspace for mac_bootstrap/ and .env/
```

## Local-only files

These are loaded if present but never committed (listed in `~/.cfg/info/exclude`):

| File | Loaded by |
| --- | --- |
| `~/.env/local.sh` | `.zshrc` (credentials, personal helpers) |
| `~/.env/work.sh` | `.zshrc` (work helpers) |
| `~/.gitconfig.work` | `.gitconfig` `[include]` (work email, host rewrites) |
| `mac_bootstrap/Brewfile.work` | `bootstrap.sh` (work-only taps and apps) |

## Managing

```bash
config status
config add -u
config commit -m "..."
config push
```
