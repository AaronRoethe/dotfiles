#!/bin/zsh

# Aaron's Dotfiles Programs Installation Script
# Installs development tools, applications, and language runtimes
# Usage: sh mac_bootstrap/install_programs.sh

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly LOG_FILE="/tmp/install_programs.log"
readonly DOWNLOADS_DIR="$HOME/Downloads"

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
        log_error "Programs installation failed with exit code $exit_code"
        log_error "Check the log file at $LOG_FILE for details"
        log_info "You can retry individual installations manually"
    fi
    exit $exit_code
}

trap cleanup EXIT

# Utility functions
command_exists() {
    command -v "$1" &> /dev/null
}

is_package_installed() {
    local package="$1"
    brew list "$package" &> /dev/null
}

is_cask_installed() {
    local cask="$1"
    brew list --cask "$cask" &> /dev/null
}

retry_command() {
    local max_attempts=3
    local attempt=1
    local cmd="$*"
    
    while [ $attempt -le $max_attempts ]; do
        if eval "$cmd"; then
            return 0
        else
            log_warning "Attempt $attempt/$max_attempts failed for: $cmd"
            if [ $attempt -eq $max_attempts ]; then
                return 1
            fi
            attempt=$((attempt + 1))
            sleep 2
        fi
    done
}

# Package arrays
declare -a brewTap=(
    "azure/functions"
)

declare -a brew=(
    "git"
    "pyenv"
    "mysql"
    "yarn"
    "n"
    "commitizen"
    "jq"
    "coreutils"
    "go"
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
    "wget"
    "nmap"
    "grep"
    "ripgrep"
    "gh"
    "gpg"
    "azure-cli"
    "azure-functions-core-tools@4"
    "sqlcmd"
)

declare -a brewCask=(
    "warp"
    "microsoft-edge"
    "bitwarden"
    "rectangle"
    "visual-studio-code"
    "slack"
    "docker"
    "mysqlworkbench"
    "logi-options-plus"
)

declare -a pythonVersions=(
    "3.10.0"
    "3.10.5"
)

declare -a nodeVersions=(
    "16.18.0"
)

declare -a npmPackages=(
    # Add global npm packages here if needed
)

# Main functions
check_prerequisites() {
    log_info "Checking prerequisites for program installation..."
    
    if ! command_exists brew; then
        log_error "Homebrew is not installed. Please run the bootstrap script first."
        exit 1
    fi
    
    # Check internet connectivity
    if ! ping -c 1 google.com &> /dev/null; then
        log_error "No internet connection detected"
        exit 1
    fi
    
    # Ensure Downloads directory exists
    mkdir -p "$DOWNLOADS_DIR"
    
    log_success "Prerequisites check passed"
}

install_homebrew_taps() {
    if [ ${#brewTap[@]} -eq 0 ]; then
        log_info "No Homebrew taps to install"
        return 0
    fi
    
    log_info "Installing Homebrew taps..."
    
    for tap in "${brewTap[@]}"; do
        if brew tap | grep -q "^$tap$"; then
            log_info "Tap already added: $tap"
        else
            log_info "Adding tap: $tap"
            if retry_command "brew tap $tap"; then
                log_success "Successfully added tap: $tap"
            else
                log_error "Failed to add tap: $tap"
                return 1
            fi
        fi
    done
    
    log_success "All Homebrew taps processed"
}

install_homebrew_packages() {
    if [ ${#brew[@]} -eq 0 ]; then
        log_info "No Homebrew packages to install"
        return 0
    fi
    
    log_info "Installing Homebrew packages..."
    
    # Update Homebrew first
    log_info "Updating Homebrew..."
    if ! brew update; then
        log_warning "Failed to update Homebrew, continuing anyway..."
    fi
    
    local failed_packages=()
    
    for tool in "${brew[@]}"; do
        if is_package_installed "$tool"; then
            log_info "Package already installed: $tool"
        else
            log_info "Installing package: $tool"
            if retry_command "brew install $tool"; then
                log_success "Successfully installed: $tool"
            else
                log_error "Failed to install: $tool"
                failed_packages+=("$tool")
            fi
        fi
    done
    
    if [ ${#failed_packages[@]} -gt 0 ]; then
        log_warning "The following packages failed to install: ${failed_packages[*]}"
        log_info "You can try installing them manually later"
    fi
    
    log_success "Homebrew packages installation completed"
}

install_homebrew_casks() {
    if [ ${#brewCask[@]} -eq 0 ]; then
        log_info "No Homebrew casks to install"
        return 0
    fi
    
    log_info "Installing Homebrew casks (applications)..."
    
    local failed_casks=()
    
    for program in "${brewCask[@]}"; do
        if is_cask_installed "$program"; then
            log_info "Cask already installed: $program"
        else
            log_info "Installing cask: $program"
            if retry_command "brew install --cask $program"; then
                log_success "Successfully installed: $program"
            else
                log_error "Failed to install: $program"
                failed_casks+=("$program")
            fi
        fi
    done
    
    if [ ${#failed_casks[@]} -gt 0 ]; then
        log_warning "The following casks failed to install: ${failed_casks[*]}"
        log_info "You can try installing them manually later"
    fi
    
    log_success "Homebrew casks installation completed"
}

install_xcode_command_line_tools() {
    log_info "Checking Xcode Command Line Tools..."
    
    if xcode-select -p &> /dev/null; then
        log_info "Xcode Command Line Tools already installed"
        return 0
    fi
    
    log_info "Installing Xcode Command Line Tools..."
    
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
        fi
    fi
}

install_python_versions() {
    if [ ${#pythonVersions[@]} -eq 0 ]; then
        log_info "No Python versions specified for installation"
        return 0
    fi
    
    if ! command_exists pyenv; then
        log_error "pyenv is not installed. Cannot install Python versions."
        return 1
    fi
    
    log_info "Installing Python versions via pyenv..."
    
    local failed_versions=()
    
    for version in "${pythonVersions[@]}"; do
        if pyenv versions --bare | grep -q "^$version$"; then
            log_info "Python $version already installed"
        else
            log_info "Installing Python $version..."
            if pyenv install "$version"; then
                log_success "Successfully installed Python $version"
            else
                log_error "Failed to install Python $version"
                failed_versions+=("$version")
            fi
        fi
    done
    
    # Set global Python version to the first one
    if [ ${#pythonVersions[@]} -gt 0 ] && [ ${#failed_versions[@]} -lt ${#pythonVersions[@]} ]; then
        log_info "Setting global Python version to ${pythonVersions[0]}"
        if pyenv global "${pythonVersions[0]}"; then
            log_success "Global Python version set to ${pythonVersions[0]}"
        else
            log_warning "Failed to set global Python version"
        fi
    fi
    
    if [ ${#failed_versions[@]} -gt 0 ]; then
        log_warning "The following Python versions failed to install: ${failed_versions[*]}"
    fi
    
    log_success "Python versions installation completed"
}

install_node_versions() {
    if [ ${#nodeVersions[@]} -eq 0 ]; then
        log_info "No Node.js versions specified for installation"
        return 0
    fi
    
    if ! command_exists n; then
        log_error "n (Node.js version manager) is not installed. Cannot install Node.js versions."
        return 1
    fi
    
    log_info "Installing Node.js versions via n..."
    
    local failed_versions=()
    
    for version in "${nodeVersions[@]}"; do
        log_info "Installing Node.js $version..."
        if sudo n "$version"; then
            log_success "Successfully installed Node.js $version"
        else
            log_error "Failed to install Node.js $version"
            failed_versions+=("$version")
        fi
    done
    
    if [ ${#failed_versions[@]} -gt 0 ]; then
        log_warning "The following Node.js versions failed to install: ${failed_versions[*]}"
    fi
    
    log_success "Node.js versions installation completed"
}

install_npm_packages() {
    if [ ${#npmPackages[@]} -eq 0 ]; then
        log_info "No global npm packages specified for installation"
        return 0
    fi
    
    if ! command_exists npm; then
        log_error "npm is not installed. Cannot install global packages."
        return 1
    fi
    
    log_info "Installing global npm packages..."
    
    local failed_packages=()
    
    for package in "${npmPackages[@]}"; do
        log_info "Installing npm package: $package"
        if sudo npm install "$package" -g; then
            log_success "Successfully installed: $package"
        else
            log_error "Failed to install: $package"
            failed_packages+=("$package")
        fi
    done
    
    if [ ${#failed_packages[@]} -gt 0 ]; then
        log_warning "The following npm packages failed to install: ${failed_packages[*]}"
    fi
    
    log_success "Global npm packages installation completed"
}

install_dotnet() {
    if command_exists dotnet; then
        log_info ".NET is already installed ($(dotnet --version))"
        return 0
    fi
    
    log_info "Installing .NET SDK..."
    
    # Determine architecture
    local arch=$(uname -m)
    local dotnet_url
    local dotnet_file
    
    if [[ "$arch" == "arm64" ]]; then
        dotnet_url="https://download.visualstudio.microsoft.com/download/pr/983c585a-6e22-458f-8632-f0f97b687ca8/8250a113e906e443c904e9cf72f118b9/dotnet-sdk-6.0.410-osx-arm64.pkg"
        dotnet_file="dotnet-sdk-6.0.410-osx-arm64.pkg"
    else
        dotnet_url="https://download.visualstudio.microsoft.com/download/pr/7a2ef636-ed0f-4e08-b92c-3fe12b5fa75c/87c1a0bb6b4fc78b6e6c8cb71e2a1f13/dotnet-sdk-6.0.410-osx-x64.pkg"
        dotnet_file="dotnet-sdk-6.0.410-osx-x64.pkg"
    fi
    
    local download_path="$DOWNLOADS_DIR/$dotnet_file"
    
    log_info "Downloading .NET SDK for $arch architecture..."
    if curl -o "$download_path" "$dotnet_url"; then
        log_success "Downloaded .NET SDK to $download_path"
        log_info "Please manually install the .NET SDK by opening: $download_path"
        log_info "The installer will guide you through the installation process"
    else
        log_error "Failed to download .NET SDK"
        return 1
    fi
}

print_installation_summary() {
    log_success "Programs installation completed!"
    echo
    log_info "Installation Summary:"
    echo "  ✓ Homebrew taps: ${#brewTap[@]} items"
    echo "  ✓ Homebrew packages: ${#brew[@]} items"
    echo "  ✓ Homebrew casks (applications): ${#brewCask[@]} items"
    echo "  ✓ Python versions: ${#pythonVersions[@]} items"
    echo "  ✓ Node.js versions: ${#nodeVersions[@]} items"
    echo "  ✓ Global npm packages: ${#npmPackages[@]} items"
    echo "  ✓ .NET SDK (download initiated)"
    echo
    log_info "Next steps:"
    echo "1. Restart your terminal to ensure all tools are in PATH"
    echo "2. If .NET was downloaded, install it from: $DOWNLOADS_DIR"
    echo "3. Configure your development tools as needed"
    echo
    log_info "For troubleshooting, check the log at: $LOG_FILE"
}

# Main execution
main() {
    log_info "Starting programs installation..."
    log_info "Log file: $LOG_FILE"
    
    check_prerequisites
    install_homebrew_taps
    install_homebrew_packages
    install_homebrew_casks
    install_python_versions
    install_node_versions
    install_npm_packages
    install_dotnet
    print_installation_summary
    
    log_success "Programs installation script completed!"
}

# Run main function
main "$@"
