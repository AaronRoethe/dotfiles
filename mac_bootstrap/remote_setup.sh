#!/bin/zsh

# Aaron's Dotfiles Complete Setup Script
# This script provides a complete one-command setup for the entire development environment
# Installs: Xcode CLI Tools, Homebrew, Git, dotfiles repository, and full development environment
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

install_xcode_command_line_tools() {
    log_info "Checking Xcode Command Line Tools..."
    
    if xcode-select -p &> /dev/null; then
        log_info "Xcode Command Line Tools already installed"
        return 0
    fi
    
    log_info "Installing Xcode Command Line Tools..."
    log_info "This provides essential tools like Git for development"
    
    # Install command line tools
    if xcode-select --install 2>/dev/null; then
        log_info "Xcode Command Line Tools installation dialog opened"
        log_info "Please follow the prompts in the dialog to accept and install"
        echo
        log_warning "⚠️  IMPORTANT: Click 'Install' in the dialog that appeared"
        log_warning "    This download is typically 300-500 MB and may take 5-30 minutes"
        log_warning "    depending on your internet connection speed"
        echo
        
        # Wait for installation to complete with progress indication
        log_info "Waiting for installation to complete..."
        local wait_time=0
        local dot_count=0
        
        while ! xcode-select -p &> /dev/null; do
            # Show progress dots
            if [ $((dot_count % 4)) -eq 0 ]; then
                printf "\r${BLUE}[INFO]${NC} Still waiting"
            elif [ $((dot_count % 4)) -eq 1 ]; then
                printf "\r${BLUE}[INFO]${NC} Still waiting."
            elif [ $((dot_count % 4)) -eq 2 ]; then
                printf "\r${BLUE}[INFO]${NC} Still waiting.."
            else
                printf "\r${BLUE}[INFO]${NC} Still waiting..."
            fi
            
            sleep 5
            wait_time=$((wait_time + 5))
            dot_count=$((dot_count + 1))
            
            # Show time elapsed every minute
            if [ $((wait_time % 60)) -eq 0 ]; then
                printf "\r${BLUE}[INFO]${NC} Still waiting... (${wait_time}s elapsed)                    \n"
                log_info "Installation is still in progress. This is normal for large downloads."
                
                # If it's been a while, provide helpful info
                if [ $wait_time -ge 300 ]; then  # 5 minutes
                    log_info "💡 Tip: Check Activity Monitor for 'Install Command Line Developer Tools' process"
                fi
                
                if [ $wait_time -ge 600 ]; then  # 10 minutes
                    log_warning "Installation is taking longer than expected."
                    log_info "You can check your internet connection or try canceling and retrying."
                fi
            fi
        done
        
        # Clear the progress line and show success
        printf "\r                                                                    \r"
        log_success "Xcode Command Line Tools installed successfully!"
        log_info "Total installation time: ${wait_time} seconds"
        
    else
        # Check if tools are being installed by another process
        if pgrep -f "Install Command Line Developer Tools" > /dev/null; then
            log_info "Xcode Command Line Tools installation already in progress"
            log_info "Waiting for existing installation to complete..."
            
            local wait_time=0
            while ! xcode-select -p &> /dev/null && pgrep -f "Install Command Line Developer Tools" > /dev/null; do
                printf "\r${BLUE}[INFO]${NC} Installation in progress... (${wait_time}s)"
                sleep 5
                wait_time=$((wait_time + 5))
            done
            printf "\r                                                    \r"
            
            if xcode-select -p &> /dev/null; then
                log_success "Xcode Command Line Tools installation completed!"
            else
                log_error "Xcode Command Line Tools installation appears to have failed"
                return 1
            fi
        else
            log_warning "Xcode Command Line Tools installation dialog may not have opened"
            log_info "You can try running 'xcode-select --install' manually"
            log_info "Or install via App Store -> Developer Tools"
            return 1
        fi
    fi
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

run_bootstrap_script() {
    log_info "Setting up complete development environment..."
    
    # Change to home directory where dotfiles should now be available
    cd "$HOME"
    
    # Check if bootstrap script exists
    if [[ ! -f "mac_bootstrap/bootstrap.sh" ]]; then
        log_error "Bootstrap script not found at mac_bootstrap/bootstrap.sh"
        log_info "You may need to restore your dotfiles first:"
        log_info "  config restore --staged . && config restore ."
        return 1
    fi
    
    log_info "Running the main bootstrap script for complete environment setup..."
    echo
    log_warning "⚠️  This will install many development tools and applications"
    log_warning "    The process may take 30-60 minutes depending on your internet speed"
    echo
    
    # Ask user if they want to continue with full bootstrap
    printf "${YELLOW}[PROMPT]${NC} Do you want to run the full bootstrap now? (y/N): "
    read -r response
    
    case "$response" in
        [yY]|[yY][eE][sS])
            log_info "Starting full bootstrap process..."
            echo
            if sh mac_bootstrap/bootstrap.sh; then
                log_success "Complete dotfiles setup finished!"
                print_completion_message
            else
                log_error "Bootstrap script failed"
                print_manual_next_steps
                return 1
            fi
            ;;
        *)
            log_info "Skipping full bootstrap"
            print_manual_next_steps
            ;;
    esac
}

print_completion_message() {
    echo
    log_success "🎉 Complete dotfiles environment setup finished!"
    echo
    log_info "Your development environment is now fully configured with:"
    echo "  ✓ Xcode Command Line Tools"
    echo "  ✓ Homebrew package manager"
    echo "  ✓ Oh My Zsh shell framework"
    echo "  ✓ Development tools and applications"
    echo "  ✓ Dotfiles repository management"
    echo
    log_info "Next steps:"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Configure Git with your details:"
    echo "   git config --global user.name \"Your Name\""
    echo "   git config --global user.email \"your.email@example.com\""
    echo "3. Set up GPG key signing (see README for instructions)"
    echo
    log_info "To manage your dotfiles: config status, config add <file>, config commit, etc."
    log_info "For more information: https://github.com/AaronRoethe/dotfiles"
}

print_manual_next_steps() {
    log_info "Remote foundation setup completed successfully!"
    echo
    log_info "To complete your development environment setup:"
    echo "1. Restore your dotfiles (if needed):"
    echo "   config restore --staged . && config restore ."
    echo "2. Run the main bootstrap script:"
    echo "   sh mac_bootstrap/bootstrap.sh"
    echo "3. Restart your terminal or run: source ~/.zshrc"
    echo
    log_info "To manage your dotfiles: config status, config add <file>, etc."
    log_info "For more information: https://github.com/AaronRoethe/dotfiles"
}

# Main execution
main() {
    log_info "Starting Aaron's Dotfiles remote setup..."
    log_info "Log file: $LOG_FILE"
    
    check_prerequisites
    install_xcode_command_line_tools
    install_homebrew
    install_git
    setup_dotfiles_repo
    configure_dotfiles_alias
    run_bootstrap_script
    
    log_success "Setup completed successfully!"
}

# Run main function
main "$@"
