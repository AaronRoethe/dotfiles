
if [ ! "$(command -v brew)" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; fi

if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; fi

mkdir $HOME/repos/go

sh ./install_programs.sh

if [ ! -d ~/.cfg ]; then
    git clone --config status.showUntrackedFiles=no --bare https://github.com/AaronRoethe/dotfiles.git $HOME/.cfg; fi
    alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
    config restore --staged . && config restore .