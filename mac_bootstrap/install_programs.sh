brewTap=(
    azure/functions
)

brew=(
    git
    pyenv 
    go
    zsh-autosuggestions
    zsh-syntax-highlighting
    wget
    nmap 
    ripgrep
    gh
    azure-cli
    azure-functions-core-tools@4
)

brewCask=(
    iterm2
    microsoft-edge
    bitwarden
    rectangle
    visual-studio-code
    spotify
    slack
    postman
    docker
    insomnia
    microsoft-remote-desktop
)

for tap in $brewTap; do
    brew tap $tap
done

for tool in $brew; do
    brew install $tool
done

for program in $brewCask; do
    brew install --cask $program
done

 
