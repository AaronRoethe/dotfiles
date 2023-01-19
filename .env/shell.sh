alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias zshrc="code ~/mac_bootstrap/config.code-workspace"
alias c="code ."
alias rf="clear && source $HOME/.zshrc"
alias rp="cd $HOME/repos"
alias localIp="ipconfig getifaddr en0"

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
checkRelease () {
	while getopts "e:" opt; do
		case "${opt}" in
			e) local enviornment="$OPTARG";;
        esac
    done
    if [ -z "$enviornment" ]; then
        echo "Error: -e (enviornment) is a required option" >&2; return
    fi
    shift $((OPTIND-1))

	cd $HOME/repos/k8s-deploy
	git checkout master -q && git pull --all -q && git pull --tags -q
	local output=$(grep targetRevision apps/rms/$enviornment/data-platform.yaml | sed 's/^[[:space:]]*//')
	echo -e "K8s-deploy:\n$output\n"

	local release=$(echo $output | awk '{print $2}')

	cd $HOME/repos/argo-apps
	git pull --tags -q && git checkout $release -q
	echo -e "argo-apps:"
	if [ $# -gt 0 ]
    then
		for arg in "$@"; do
			local targetService=$arg
			local output=$(grep newTag data-platform/overlay/$enviornment/$targetService/kustomization.yaml | sed 's/^[[:space:]]*//')
			echo -e "$targetService\n$output"
		done
	else
		local output=$(grep newTag data-platform/overlay/$enviornment/translator/kustomization.yaml | sed 's/^[[:space:]]*//')
		echo -e "translator\n$output"
    fi
		git checkout master -q
}
