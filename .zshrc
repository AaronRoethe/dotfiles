export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(
    git
    dotenv
    copypath
    copyfile
    copybuffer
)

source $ZSH/oh-my-zsh.sh

ZSH_DOTENV_FILE=.env
ZSH_DOTENV_PROMPT=true

for config in $HOME/.env/*.sh; do
    source ${config}
done
