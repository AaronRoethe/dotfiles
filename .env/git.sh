alias gs="git stash"
alias gsp="git stash pop"

prMsg () {
    echo "================== Last Pull Request > clipboard =================="
    gh pr list --state open --author @me --json additions,deletions,title,url,headRepository --limit 10 --template \
        '{{range .}}*[{{.headRepository.name}}]* `+{{.additions}} -{{.deletions}}` {{.title}}{{"\n"}}{{.url}}{{"\n"}}{{end}}' | tee >(pbcopy)
    echo "==================================================================="
}

# Delete the current repo directory and clone it fresh from its remote
git_reclone() {
    local root url
    root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "not a git repo" >&2; return 1; }
    url=$(git remote get-url origin 2>/dev/null || git remote get-url "$(git remote | head -n 1)") || { echo "no remote" >&2; return 1; }

    echo "Repository: $root"
    echo "Remote URL: $url"
    echo "WARNING: deletes the directory and re-clones. Uncommitted changes will be lost."
    read "confirm?Type 'yes' to continue: "
    [[ "$confirm" == "yes" ]] || { echo "Aborted."; return 1; }

    cd "$(dirname "$root")" && rm -rf "$root" && git clone "$url" "$root" && cd "$root"
}

# Repack refs and drop empty remote ref dirs, then pull
git-pullfix() {
    local gitdir
    gitdir=$(git rev-parse --git-dir 2>/dev/null) || { echo "not a git repo" >&2; return 1; }
    git pack-refs --all --prune &&
    find "$gitdir/refs/remotes" -type d -empty -delete 2>/dev/null
    git pull
}
