alias glog="git log --graph --pretty='%Cred%h%Creset %Cgreen(%ad) %C(bold blue)%<(12,trunc)<%an> %C(auto)%d%Creset%<(80,trunc)%s' --date=short"
alias ggpush="git push origin $(git_current_branch) -u"

githome () { gcm && ggpull }

mergedBranch () { gcm && ggpull && gfa && gbda }

