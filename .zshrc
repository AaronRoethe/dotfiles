export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
    git
    dotenv
    zsh-autosuggestions
    zsh-syntax-highlighting
    copypath
    copyfile
    copybuffer
)

bindkey "^ " autosuggest-accept

source $ZSH/oh-my-zsh.sh

# User configuration

for config in $HOME/.env/*.sh;do
    source ${config}
done

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
