brewTap=(
    azure/functions
)

brew=(
    git
    pyenv
    mysql
    yarn
    n
    commitizen
    jq
    coreutils
    go
    zsh-autosuggestions
    zsh-syntax-highlighting
    wget
    nmap
    grep
    ripgrep
    gh
    gpg
    azure-cli
    azure-functions-core-tools@4
)

brewCask=(
    warp
    microsoft-edge
    bitwarden
    rectangle
    visual-studio-code
    spotify
    discord
    slack
    docker
    insomnia
    mysqlworkbench
    microsoft-remote-desktop
    logi-options-plus
)

for tap in "${brewTap[@]}"; do
    brew tap $tap
done

for tool in "${brew[@]}"; do
    brew install $tool
done

for program in "${brewCask[@]}"; do
    brew install --cask $program
done

# Mac setup
xcode-select --install

# program laugage versions
pythonVersions=(
    3.10.0
    3.10.5
)
nodeVersions=(
    16.18.0
)

for version in "${pythonVersions[@]}"; do
    pyenv install $version
done

for version in "${nodeVersions[@]}"; do
    sudo n $version
done

# global packages
npmPackages=(
)

for program in "${npmPackages[@]}"; do
    sudo npm install $program -g
done

# dotnet
if [ ! "$(command -v dotnet)" ]; then
    curl -o ~/Downloads/dotnet-sdk-6.0.410-osx-arm64.pkg https://download.visualstudio.microsoft.com/download/pr/983c585a-6e22-458f-8632-f0f97b687ca8/8250a113e906e443c904e9cf72f118b9/dotnet-sdk-6.0.410-osx-arm64.pkg; fi
