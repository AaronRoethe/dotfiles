
#!/bin/zsh

# Aaron's Dotfiles Bootstrap Script
# Main orchestrator for setting up the complete development environment
# Usage: sh mac_bootstrap/bootstrap.sh

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/tmp/bootstrap_setup.log"
readonly GO_DIR="$HOME/repos/go"
readonly OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"

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
        log_error "Bootstrap script failed with exit code $exit_code"
        log_error "Check the log file at $LOG_FILE for details"
        log_info "You can try running individual components manually:"
        log_info "  - Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        log_info "  - Oh My Zsh: sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
        log_info "  - Programs: sh $SCRIPT_DIR/install_programs.sh"
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

create_directory_safe() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        if mkdir -p "$dir"; then
            log_success "Created directory: $dir"
        else
            log_error "Failed to create directory: $dir"
            return 1
        fi
    else
        log_info "Directory already exists: $dir"
    fi
}

# Main functions
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! is_macos; then
        log_error "This script is designed for macOS only"
        exit 1
    fi
    
    # Check internet connectivity
    if ! ping -c 1 google.com &> /dev/null; then
        log_error "No internet connection detected"
        exit 1
    fi
    
    # Check if script is run from the correct location
    if [[ ! -f "$SCRIPT_DIR/install_programs.sh" ]]; then
        log_error "install_programs.sh not found in script directory"
        log_error "Please ensure you're running this script from the mac_bootstrap directory"
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
    log_info "This is required before installing Homebrew and other development tools"
    
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
        log_info "Homebrew is already installed ($(brew --version | head -n1))"
        
        # Update Homebrew
        log_info "Updating Homebrew..."
        if brew update; then
            log_success "Homebrew updated successfully"
        else
            log_warning "Failed to update Homebrew, continuing anyway..."
        fi
        return 0
    fi
    
    log_info "Installing Homebrew..."
    
    # Install Homebrew
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        log_success "Homebrew installed successfully"
        
        # Ensure Homebrew is in PATH
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        log_error "Failed to install Homebrew"
        return 1
    fi
}

install_oh_my_zsh() {
    if [[ -d "$OH_MY_ZSH_DIR" ]]; then
        log_info "Oh My Zsh is already installed"
        
        # Update Oh My Zsh
        log_info "Updating Oh My Zsh..."
        if [[ -f "$OH_MY_ZSH_DIR/tools/upgrade.sh" ]]; then
            env ZSH="$OH_MY_ZSH_DIR" sh "$OH_MY_ZSH_DIR/tools/upgrade.sh" || log_warning "Failed to update Oh My Zsh"
        fi
        return 0
    fi
    
    log_info "Installing Oh My Zsh..."
    
    # Install Oh My Zsh (unattended)
    if sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        log_success "Oh My Zsh installed successfully"
    else
        log_error "Failed to install Oh My Zsh"
        return 1
    fi
}

setup_go_directory() {
    log_info "Setting up Go workspace directory..."
    
    # Create Go workspace directory
    if create_directory_safe "$GO_DIR"; then
        log_success "Go workspace directory ready at $GO_DIR"
    else
        log_error "Failed to create Go workspace directory"
        return 1
    fi
}

install_programs() {
    log_info "Installing programs and packages..."
    
    local install_script="$SCRIPT_DIR/install_programs.sh"
    
    if [[ ! -f "$install_script" ]]; then
        log_error "Install programs script not found: $install_script"
        return 1
    fi
    
    # Make the script executable
    chmod +x "$install_script"
    
    # Run the install programs script
    if sh "$install_script"; then
        log_success "Programs installation completed"
    else
        log_error "Programs installation failed"
        return 1
    fi
}

set_shell_to_zsh() {
    local current_shell=$(echo $SHELL)
    
    if [[ "$current_shell" == *"zsh"* ]]; then
        log_info "Shell is already set to zsh"
        return 0
    fi
    
    log_info "Setting shell to zsh..."
    
    local zsh_path
    if command_exists zsh; then
        zsh_path=$(which zsh)
        
        # Add zsh to allowed shells if not already there
        if ! grep -q "$zsh_path" /etc/shells; then
            log_info "Adding zsh to /etc/shells..."
            echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
        fi
        
        # Change shell
        if chsh -s "$zsh_path"; then
            log_success "Shell changed to zsh successfully"
            log_info "Please restart your terminal for the change to take effect"
        else
            log_warning "Failed to change shell to zsh automatically"
            log_info "You can change it manually with: chsh -s $zsh_path"
        fi
    else
        log_error "zsh not found"
        return 1
    fi
}

print_completion_message() {
    log_success "Bootstrap setup completed successfully!"
    echo
    log_info "What was installed/configured:"
    echo "  ✓ Xcode Command Line Tools"
    echo "  ✓ Homebrew package manager"
    echo "  ✓ Oh My Zsh shell framework"
    echo "  ✓ Development tools and applications"
    echo "  ✓ Go workspace directory at $GO_DIR"
    echo "  ✓ Shell configuration"
    echo
    log_info "Next steps:"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Configure Git with your name and email:"
    echo "   git config --global user.name \"Your Name\""
    echo "   git config --global user.email \"your.email@example.com\""
    echo "3. Set up GPG key signing (see README for instructions)"
    echo "4. Customize your environment as needed"
    echo
    log_info "For troubleshooting, check the log at: $LOG_FILE"
}

# Main execution
main() {
    log_info "Starting Aaron's Dotfiles bootstrap..."
    log_info "Log file: $LOG_FILE"
    log_info "Script directory: $SCRIPT_DIR"
    
    check_prerequisites
    install_xcode_command_line_tools
    install_homebrew
    install_oh_my_zsh
    setup_go_directory
    install_programs
    set_shell_to_zsh
    print_completion_message
    
    log_success "Bootstrap completed successfully!"
}

# Run main function
main "$@"
