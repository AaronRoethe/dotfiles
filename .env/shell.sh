alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias zshrc="open ~/.zshrc"
alias c="code ."
alias rf="clear && exec $SHELL"
alias rp="cd ~/repos"
alias localIp="ipconfig getifaddr en0"

repos=(
	terraform-integrations 
	darkwing-dotnet 
	darkwing-sql 
	DBScripts 
	Infrastructure
)

ag () {alias | grep $1} 
lineBreak () {printf -- '~%.0s' {1..50}; printf '\n'}
repos () {
    for i in $repos;do
        lineBreak; echo $i; lineBreak
	cd ~/repos/$i && $1
	done; cd ~/repos
}
