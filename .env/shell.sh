alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias zshrc="code ~/mac_bootstrap/config.code-workspace"
alias c="code ."
alias rf="clear && source $HOME/.zshrc"
alias rp="cd $HOME/repos"
alias myIp="curl api.ipify.org && echo '\n'`ipconfig getifaddr en0`"
alias projects="code ~/OneDrive\ -\ Axon\ Enterprise/projects"
alias integrations="code ~/repos/integrations/integrations-testing"
alias datastore="code ~/repos/datastore/datastore-deployment-tool"

ag () {
	alias | grep $1
}

whatis () {
	declare -f $1
}

lineBreak () {
	printf -- '~%.0s' {1..50}; printf '\n'
}

addConfig () {
	for file in `config status -s | awk '{print $2}'`;do
		if [[ ${file##*/} != '.gitconfig' ]]; then
			config add $file; fi 
		done
	config status
	# Use the following to add chunks of a file
	# config add -p
}

showConfigChanges () {
	config diff --cached
}