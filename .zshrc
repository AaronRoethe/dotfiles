export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
    git
    dotenv
    copypath
    copyfile
    copybuffer
)

bindkey "^ " autosuggest-accept

source $ZSH/oh-my-zsh.sh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# User configuration
ZSH_DOTENV_FILE=.env
ZSH_DOTENV_PROMPT=true
ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd*|git*|\.+"

for config in $HOME/.env/*.sh;do
    source ${config}
done

echo "Welcome Back Aaron, Happy Coding!"
