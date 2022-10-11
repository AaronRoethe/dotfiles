brew=(
    git 
    pyenv 
    go 
    wget 
    nmap 
    ripgrep
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

for tool in $brew; do
    brew install $tool
done

for program in $brewCask; do
    brew install --cask  $program
done

 
