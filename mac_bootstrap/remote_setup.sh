#!/bin/bash

# Check if Homebrew is installed, and install if necessary
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH for new installations
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew is already installed."
fi

# Install Git using Homebrew if not installed
if ! command -v git &> /dev/null; then
  echo "Installing Git..."
  brew install git
else
  echo "Git is already installed."
fi

# Clone dotfiles repository as a bare repo if it doesn't already exist
if [ ! -d "$HOME/.cfg" ]; then
  echo "Cloning dotfiles repository..."
  git clone --bare https://github.com/AaronRoethe/dotfiles.git $HOME/.cfg
else
  echo "The dotfiles repository already exists."
fi

# Create and persist the config alias for managing dotfiles
if ! grep -q "alias config" ~/.zshrc; then
  echo "alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> ~/.zshrc
fi

source ~/.zshrc
# Set Git to not show untracked files for the dotfiles
config config --local status.showUntrackedFiles no

echo "Dotfiles repository cloned and alias set up."
