alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias zshrc="code ~/mac_bootstrap/config.code-workspace"
alias c="code ."
alias rf="clear && source $HOME/.zshrc"
alias rp="cd $HOME/repos"
alias myIp="curl api.ipify.org && echo '\n'`ipconfig getifaddr en0`"
alias projects="code ~/OneDrive\ -\ Axon\ Enterprise/projects"
alias integrations="code ~/repos/integrations/integrationTesting"
alias datastore="code ~/repos/datastore/datastore-deployment-tool"

workingRepos=(
	terraform-integrations 
	darkwing-dotnet 
	darkwing-sql 
	DBScripts 
	Infrastructure
	translator
	conductor
	DseRepo
	datastore-deployment-tool
)

ag () {
	alias | grep $1
} 
lineBreak () {
	printf -- '~%.0s' {1..50}; printf '\n'
}
repos () {
    for i in $workingRepos;do
		# change to repos directory
        cd ~/repos/$i && 
		# check optional command to delete remoted merged branchs
		if [[ "${1:-no}" == "gbDa" ]];then 
			git fetch -p -q && for branch in `git branch -vv | grep ': gone]' | awk '{print $1}'`; do git branch -D $branch ; done
		fi &&
		# save all of my living branches
		branches=$(for branch in `git branch -vv | grep 'aroethe' | awk '{print $1}'`; do echo $branch; done)
		if [ -z $branches ]; then
		# if branch available print name & repo 
		else echo $i && lineBreak && echo $branches && lineBreak && printf '\n';fi
	done; cd ~/repos
}
addConfig () {
	for file in `config status -s | awk '{print $2}'`;do
		if [[ ${file##*/} != '.gitconfig' ]]; then
			config add $file; fi 
		done
	config status
}