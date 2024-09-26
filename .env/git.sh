alias glog="git log --graph --decorate-refs='refs/heads/*' --pretty='%Cred%h%Creset %Cgreen(%ad) %C(bold blue)%<(16,trunc)<%an> %C(auto)%d%Creset%<(80,trunc)%s' --date=short"
alias gs="git stash" 
alias gsp="git stash pop"

githome () { 
    git stash -q
    git checkout $(git_main_branch) -q && git pull origin $(git_main_branch) -q
    git stash pop
}

prMsg () {
    echo "================== Last Pull Request > clipboard =================="
    gh pr list --state open --author aroethe --json additions,deletions,title,url,headRepository --limit 1 --template \
        '{{range .}}*[{{.headRepository.name}}]* `+{{.additions}} -{{.deletions}}` {{.title}}{{"\n"}}{{.url}}{{"\n"}}{{end}}' | tee >(pbcopy)
    echo "==================================================================="
}

createPR () {
    # push and link local to origin
    git push origin $(git symbolic-ref --short HEAD) -u -q
    # create PR
    gh pr create -B $(git_main_branch) -H "$(git symbolic-ref --short HEAD)"
    # print PRs
    prMsg
}

push-to-develop() {
  feature_branch=$(git rev-parse --abbrev-ref HEAD)
  git checkout develop
  git pull
  git merge --no-edit ${feature_branch}
  git push origin $(git rev-parse --abbrev-ref HEAD)
  git checkout -
}