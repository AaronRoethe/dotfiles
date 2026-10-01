alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias zshrc="code ~/mac_bootstrap/config.code-workspace"
alias c="code ."
alias rf="clear && source $HOME/.zshrc"
alias rp="cd $HOME/repos"
alias myIp='curl -s api.ipify.org; echo; ipconfig getifaddr en0'

# Replacements for the oh-my-zsh copypath/copyfile plugins
alias copypath='print -n "$PWD" | pbcopy'
copyfile() { pbcopy < "$1"; }

# Replacement for the oh-my-zsh dotenv plugin: offer to load ./.env on cd
_load_dotenv() {
    [[ -f .env ]] || return
    read -q "?Source $PWD/.env? [y/N] " && { echo; set -a; source .env; set +a; } || echo
}
autoload -U add-zsh-hook
add-zsh-hook chpwd _load_dotenv
