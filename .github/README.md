# Aaron's Dotfiles 🔧

A comprehensive macOS development environment setup using bare git repository for dotfiles management. This repository automates the installation and configuration of essential development tools, applications, and personalized settings.

## 🚀 Quick Start

### One-Line Remote Setup
For a completely fresh Mac setup, run this single command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/AaronRoethe/dotfiles/master/mac_bootstrap/remote_setup.sh)"
```

This script will:
- Install Homebrew (if not present)
- Install Git
- Clone this dotfiles repository as a bare repo
- Set up the `config` alias for managing dotfiles

### Manual Setup
If you prefer to set up manually or already have some components installed:

1. **Clone the repository as a bare repo:**
   ```bash
   git clone --bare https://github.com/AaronRoethe/dotfiles.git $HOME/.cfg
   ```

2. **Set up the config alias:**
   ```bash
   alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
   ```

3. **Configure git to not show untracked files:**
   ```bash
   config config --local status.showUntrackedFiles no
   ```

4. **⚠️ WARNING: Restore dotfiles (this will overwrite existing files):**
   ```bash
   config restore --staged . && config restore .
   ```

5. **Run the main bootstrap script:**
   ```bash
   sh mac_bootstrap/bootstrap.sh
   ```

## 📁 Repository Structure

```
dotfiles/
├── mac_bootstrap/           # Main setup scripts
│   ├── bootstrap.sh         # Primary setup orchestrator
│   ├── install_programs.sh  # Package and application installer
│   ├── remote_setup.sh      # Remote one-line setup script
│   ├── config-iterm.json    # iTerm2 configuration
│   ├── config-rectangle.json # Rectangle window manager config
│   └── config.code-workspace # VS Code workspace setup
├── repos/utils/             # Utility scripts and tools
│   ├── requirements.txt     # Python dependencies
│   └── script.sh           # Template utility script
└── .github/README.md        # This documentation
```

## 🛠 What Gets Installed

### Package Managers & Core Tools
- **Homebrew** - macOS package manager
- **Oh My Zsh** - Enhanced shell experience

### Development Tools
- **Languages & Runtimes:**
  - Python (3.10.0, 3.10.5 via pyenv)
  - Node.js (16.18.0 via n)
  - Go
  - .NET SDK 6.0.410

- **Version Control & CLI:**
  - Git with GPG signing support
  - GitHub CLI (gh)
  - Azure CLI & Functions Core Tools

- **Database Tools:**
  - MySQL Server & Workbench
  - sqlcmd

### Applications (via Homebrew Cask)
- **Terminal & Editors:**
  - Warp Terminal
  - Visual Studio Code
  
- **Productivity:**
  - Rectangle (window management)
  - Bitwarden (password manager)

- **Development:**
  - Docker

- **Communication & Media:**
  - Slack
  - Microsoft Edge

- **Utilities:**
  - Logi Options+ (for Logitech devices)

### Command Line Utilities
- `commitizen` - Standardized commit messages
- `jq` - JSON processor
- `coreutils` - GNU core utilities
- `zsh-autosuggestions` & `zsh-syntax-highlighting`
- `wget`, `nmap`, `grep`, `ripgrep`

## 🔐 Git Commit Signing Setup

After running the bootstrap, set up GPG commit signing:

1. **Generate a GPG key:**
   ```bash
   gpg --full-generate-key
   ```
   Choose "RSA and RSA" when prompted.

2. **List your keys:**
   ```bash
   gpg --list-secret-keys --keyid-format=long
   ```

3. **Export your public key:**
   ```bash
   gpg --armor --export <key-id>
   ```

4. **Configure Git:**
   ```bash
   git config --global user.signingKey <key-id>
   ```

5. **Add the public key to GitHub:**
   - Go to GitHub Settings → SSH and GPG keys
   - Add the exported public key

For detailed instructions, see: [GitHub's GPG Key Documentation](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)

## ⚙️ Included Configurations

### iTerm2 (`config-iterm.json`)
- Custom color scheme optimized for development
- Working directory set to `~/repos`
- Enhanced keyboard mappings
- CPU, memory, and network monitoring in status bar
- Custom "Welcome Brother" window title

### Rectangle (`config-rectangle.json`)
- Window management shortcuts using Cmd+Option combinations
- Snap areas configured for productivity
- Launch on login enabled

### VS Code Workspace (`config.code-workspace`)
- Multi-folder workspace including:
  - mac_bootstrap scripts
  - .ssh configurations
  - Environment files
  - Utility scripts

## 🔄 Managing Your Dotfiles

After setup, use the `config` alias to manage your dotfiles:

```bash
# Check status
config status

# Add new files
config add .vimrc

# Commit changes
config commit -m "Add vim configuration"

# Push changes
config push

# Pull updates
config pull
```

## 🎯 Customization

### Adding New Packages
Edit `mac_bootstrap/install_programs.sh` and modify the arrays:
- `brew=()` - for command-line tools
- `brewCask=()` - for GUI applications
- `brewTap=()` - for additional repositories

### Adding New Configurations
1. Add your config files to the repository
2. Use `config add <file>` to track them
3. Commit and push your changes

## 🔧 Utility Scripts

The `repos/utils/` directory contains template scripts for common tasks:
- `script.sh` - Template shell script with argument parsing
- `requirements.txt` - Python dependencies for utility scripts

## 📝 Notes

- The bare repository approach keeps your dotfiles separate from your working directory
- Untracked files in your home directory won't show up in `config status`
- Always test changes in a safe environment before applying to your main system
- The setup creates a `~/repos/go` directory for Go development

## 🤝 Contributing

Feel free to fork this repository and adapt it for your own needs. If you find improvements that could benefit others, pull requests are welcome!

---

*This setup is optimized for macOS development with a focus on productivity and developer experience.*
