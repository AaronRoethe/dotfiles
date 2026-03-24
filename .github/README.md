# Aaron's Dotfiles

A macOS development environment using a bare git repository for dotfiles management.

## Quick Start

### One-Line Remote Setup
For a fresh Mac, run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/AaronRoethe/dotfiles/master/mac_bootstrap/remote_setup.sh)"
```

### Manual Setup

1. **Clone as a bare repo:**
   ```bash
   git clone --bare https://github.com/AaronRoethe/dotfiles.git $HOME/.cfg
   ```

2. **Set up the config alias:**
   ```bash
   alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
   ```

3. **Hide untracked files:**
   ```bash
   config config --local status.showUntrackedFiles no
   ```

4. **⚠️ Restore dotfiles (overwrites existing files):**
   ```bash
   config restore --staged . && config restore .
   ```

5. **Run the bootstrap script:**
   ```bash
   sh mac_bootstrap/bootstrap.sh
   ```

## Repository Structure

```
dotfiles/
├── .env/
│   ├── exports.sh           # PATH and environment variables
│   ├── git.sh               # Git aliases and functions
│   ├── python.sh            # Python helpers and venv management
│   └── shell.sh             # Shell aliases and utility functions
├── .gitconfig               # Git configuration and aliases
├── .zshrc                   # Zsh entry point, sources .env/*.sh
└── mac_bootstrap/
    ├── bootstrap.sh         # Setup orchestrator
    ├── install_programs.sh  # Package and application installer
    ├── remote_setup.sh      # One-line fresh Mac setup
    ├── config-rectangle.json # Rectangle window manager config
    └── config.code-workspace # VS Code workspace
```

## What Gets Installed

### Package Managers & Core Tools
- **Homebrew** — macOS package manager
- **Oh My Zsh** — Shell framework (plugins: git, dotenv, copypath, copyfile, copybuffer)

### Languages & Runtimes
- Python 3.12.9 & 3.13.2 (via pyenv)
- Node.js 22 LTS (via nvm)
- Go
- .NET SDK

### Version Control & CLI
- Git, GitHub CLI (`gh`)
- Azure CLI & Functions Core Tools

### Database Tools
- MySQL & MySQL Workbench
- sqlcmd

### Applications
- Warp Terminal
- Visual Studio Code
- Rectangle (window management)
- Bitwarden, Docker, Slack, Microsoft Edge
- Logi Options+

### Command Line Utilities
- `commitizen`, `jq`, `coreutils`
- `wget`, `nmap`, `grep`, `ripgrep`

## Included Configurations

### Rectangle (`config-rectangle.json`)
- Window management shortcuts via Cmd+Option combinations
- Launch on login enabled

### VS Code Workspace (`config.code-workspace`)
- Multi-folder workspace: mac_bootstrap, .ssh, .env files

## Managing Dotfiles

```bash
# Check status
config status

# Stage all changed tracked files
addConfig

# Commit and push
config commit -m "update configs"
config push
```

## SSH Setup (Multiple GitHub Accounts)

This repo uses SSH with separate keys for personal and work GitHub accounts. Configure `~/.ssh/config`:

```
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/personal_private_key
    IdentitiesOnly yes

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
```

The `.gitconfig` URL rewrites route repos to the correct key automatically.
