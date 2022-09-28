export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
plugins=(
    git
    dotenv
    zsh-autosuggestions
    zsh-syntax-highlighting
    copypath
    copyfile
    copybuffer
)

ZSH_DOTENV_FILE=.env
ZSH_DOTENV_PROMPT=false

ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd*|git*"
#ZSH_AUTOSUGGEST_COMPLETION_IGNORE="gc*+"
bindkey "^ " autosuggest-accept

source $ZSH/oh-my-zsh.sh

# User configuration

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# exports

# shell

alias config="open ~/.zshrc"
alias rf="clear && exec $SHELL"
alias rp="cd ~/repos"
alias repoList="echo terraform-integrations darkwing-dotnet darkwing-sql DBScripts Infrastructure" 

ag () {alias | grep $1} 
lineBreak () {printf -- '~%.0s' {1..50}; printf '\n'}
repos () {
    for i in `repoList`;do
        lineBreak; echo $i; lineBreak
	cd ~/repos/$i && `$1`
	done; cd ~/repos
}

# git

alias glog="git log --graph --pretty='%Cred%h%Creset %Cgreen(%ad) %C(bold blue)%<(12,trunc)<%an> %C(auto)%d%Creset%<(80,trunc)%s' --date=short"
alias ggpush="git push origin $(git_current_branch) -u"

githome () { gcm && ggpull }

mergedBranch () { gcm && ggpull && gfa && gbda }

# python

alias pyActivate="source .venv/bin/activate" 

pyCreate () {
	if [ -d .venv ];then 
	    rm -rf .venv; fi &&
	
	if [ -f .python-version ];then
	    pyVersion="local"
	else
	    pyVersion="global"; fi &&

	location=${1:-requirements.txt} &&

	if [ -f $location ];then
	    action=(pip install -r $location)
	else
	    action=(echo "\n No file: $location \n"); fi &&	

	PYENV_VERSION=`pyenv $pyVersion` python -m venv .venv &&
	source .venv/bin/activate &&
	pip install --upgrade pip && $action
}



