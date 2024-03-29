alias glog="git log --graph --pretty='%Cred%h%Creset %Cgreen(%ad) %C(bold blue)%<(12,trunc)<%an> %C(auto)%d%Creset%<(80,trunc)%s' --date=short"
alias gs="git stash" 
alias gsp="git stash pop"

githome () { 
    git stash -q
    git checkout master -q && git pull origin master -q
    git stash pop    
}

prMsg () {
    gh pr list --state open --author aroethe --json additions,deletions,title,url,headRepository --template \
    '{{range .}}*[{{.headRepository.name}}]* `+{{.additions}} -{{.deletions}}` {{.title}}{{"\n"}}{{.url}}{{"\n"}}{{end}}' | tee >(pbcopy)
}

createPR () {
    gh pr create -B master -H "$(git symbolic-ref --short HEAD)"
    prMsg
}