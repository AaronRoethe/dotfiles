alias zshrc="open ~/.zshrc"
alias rf="clear && exec $SHELL"
alias rp="cd ~/repos"
repoList="
	terraform-integrations 
	darkwing-dotnet 
	darkwing-sql 
	DBScripts 
	Infrastructure" 

ag () {alias | grep $1} 
lineBreak () {printf -- '~%.0s' {1..50}; printf '\n'}
repos () {
    for i in $repoList;do
        lineBreak; echo $i; lineBreak
	cd ~/repos/$i && `$1`
	done; cd ~/repos
}
