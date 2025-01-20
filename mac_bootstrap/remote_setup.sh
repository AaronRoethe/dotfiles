#!/bin/bash

# Check if Homebrew is installed, if not install it
if ! command -v brew &> /dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew is already installed."
fi

# Add Homebrew to PATH (for new installations)
if ! command -v brew &> /dev/null; then
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install Git using Homebrew
if ! command -v git &> /dev/null; then
  echo "Installing Git..."
  brew install git
else
  echo "Git is already installed."
fi

# Print success message
echo "Git is installed. You can now clone your dotfile repository."
