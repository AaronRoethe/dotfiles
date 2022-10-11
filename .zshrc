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
ZSH_DOTENV_FILE=.env
ZSH_DOTENV_PROMPT=false
ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd*|git*"

for config in $HOME/.env/*.sh;do
    source ${config}
done
