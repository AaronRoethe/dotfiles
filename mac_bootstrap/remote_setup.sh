#!/bin/zsh

# Aaron's Dotfiles Remote Setup Script
# This script sets up the essential components for dotfiles management
# Usage: curl -fsSL https://raw.githubusercontent.com/AaronRoethe/dotfiles/master/mac_bootstrap/remote_setup.sh | bash

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly DOTFILES_REPO="https://github.com/AaronRoethe/dotfiles.git"
readonly CONFIG_DIR="$HOME/.cfg"
readonly LOG_FILE="/tmp/dotfiles_setup.log"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Error handling
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Script failed with exit code $exit_code"
        log_error "Check the log file at $LOG_FILE for details"
    fi
    exit $exit_code
}

trap cleanup EXIT

# Utility functions
command_exists() {
    command -v "$1" &> /dev/null
}

is_macos() {
    [[ "$OSTYPE" == "darwin"* ]]
}

get_arch() {
    uname -m
}

# Main functions
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! is_macos; then
        log_error "This script is designed for macOS only"
        exit 1
    fi
    
    # Check if running on supported architecture
    local arch=$(get_arch)
    log_info "Detected architecture: $arch"
    
    # Check internet connectivity
    if ! ping -c 1 google.com &> /dev/null; then
        log_error "No internet connection detected"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

install_homebrew() {
    if command_exists brew; then
        log_info "Homebrew is already installed"
        return 0
    fi
    
    log_info "Installing Homebrew..."
    
    # Download and install Homebrew
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        log_error "Failed to install Homebrew"
        return 1
    fi
    
    # Determine Homebrew path based on architecture
    local brew_path
    if [[ $(get_arch) == "arm64" ]]; then
        brew_path="/opt/homebrew/bin/brew"
    else
        brew_path="/usr/local/bin/brew"
    fi
    
    # Add Homebrew to PATH for current session and future sessions
    if [[ -f "$brew_path" ]]; then
        eval "$($brew_path shellenv)"
        
        # Add to shell profile
        local shell_profile="$HOME/.zprofile"
        if ! grep -q "brew shellenv" "$shell_profile" 2>/dev/null; then
            echo 'eval "$('$brew_path' shellenv)"' >> "$shell_profile"
            log_info "Added Homebrew to $shell_profile"
        fi
    else
        log_error "Homebrew installation failed - brew binary not found at $brew_path"
        return 1
    fi
    
    log_success "Homebrew installed successfully"
}

install_git() {
    if command_exists git; then
        log_info "Git is already installed ($(git --version))"
        return 0
    fi
    
    log_info "Installing Git via Homebrew..."
    
    if ! brew install git; then
        log_error "Failed to install Git"
        return 1
    fi
    
    log_success "Git installed successfully"
}

setup_dotfiles_repo() {
    if [[ -d "$CONFIG_DIR" ]]; then
        log_warning "Dotfiles directory already exists at $CONFIG_DIR"
        
        # Check if it's a valid git repository
        if git --git-dir="$CONFIG_DIR" --work-tree="$HOME" status &> /dev/null; then
            log_info "Existing dotfiles repository appears to be valid"
            return 0
        else
            log_warning "Existing directory is not a valid git repository, removing..."
            rm -rf "$CONFIG_DIR"
        fi
    fi
    
    log_info "Cloning dotfiles repository..."
    
    # Clone the repository
    if ! git clone --bare "$DOTFILES_REPO" "$CONFIG_DIR"; then
        log_error "Failed to clone dotfiles repository"
        return 1
    fi
    
    log_success "Dotfiles repository cloned successfully"
}

configure_dotfiles_alias() {
    log_info "Setting up dotfiles configuration..."
    
    # Create the config function for current session
    config() {
        /usr/bin/git --git-dir="$CONFIG_DIR" --work-tree="$HOME" "$@"
    }
    
    # Configure git settings for the dotfiles repository
    if ! config config --local status.showUntrackedFiles no; then
        log_error "Failed to configure git settings for dotfiles"
        return 1
    fi
    
    # Add the alias to shell configuration
    local shell_config="$HOME/.zshrc"
    local alias_line="alias config='/usr/bin/git --git-dir=\$HOME/.cfg/ --work-tree=\$HOME'"
    
    if [[ -f "$shell_config" ]] && grep -q "alias config=" "$shell_config"; then
        log_info "Config alias already exists in $shell_config"
    else
        echo "$alias_line" >> "$shell_config"
        log_info "Added config alias to $shell_config"
    fi
    
    log_success "Dotfiles configuration completed"
}

print_next_steps() {
    log_success "Remote setup completed successfully!"
    echo
    log_info "Next steps:"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Run the main bootstrap script: sh mac_bootstrap/bootstrap.sh"
    echo "3. To manage your dotfiles, use: config status, config add <file>, etc."
    echo
    log_info "For more information, see the README at: https://github.com/AaronRoethe/dotfiles"
}

# Main execution
main() {
    log_info "Starting Aaron's Dotfiles remote setup..."
    log_info "Log file: $LOG_FILE"
    
    check_prerequisites
    install_homebrew
    install_git
    setup_dotfiles_repo
    configure_dotfiles_alias
    print_next_steps
    
    log_success "Setup completed successfully!"
}

# Run main function
main "$@"
