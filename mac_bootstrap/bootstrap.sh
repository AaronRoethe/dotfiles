
if [ ! "$(command -v brew)" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; fi

if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; fi

plugins="
    zsh-syntax-highlighting
    zsh-autosuggestions
    "

for plugin in $plugins; do
    location=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/${plugin}
    echo $location
    if [ ! -d $location ]; then
        git clone https://github.com/zsh-users/${plugin}.git $location
    fi
done

sh ./install_programs.sh
