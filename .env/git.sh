alias gs="git stash"
alias gsp="git stash pop"

prMsg () {
    echo "================== Last Pull Request > clipboard =================="
    gh pr list --state open --author aroethe --json additions,deletions,title,url,headRepository --limit 10 --template \
        '{{range .}}*[{{.headRepository.name}}]* `+{{.additions}} -{{.deletions}}` {{.title}}{{"\n"}}{{.url}}{{"\n"}}{{end}}' | tee >(pbcopy)
    echo "==================================================================="
}

git_nuke() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi

    # Get the repository root directory
    local repo_root
    repo_root=$(git rev-parse --show-toplevel)
    
    if [ -z "$repo_root" ]; then
        echo "Error: Could not determine repository root" >&2
        return 1
    fi

    # Get the remote URL (prefer origin, fallback to first remote)
    local remote_url
    if git remote get-url origin > /dev/null 2>&1; then
        remote_url=$(git remote get-url origin)
    else
        local first_remote
        first_remote=$(git remote | head -n 1)
        if [ -z "$first_remote" ]; then
            echo "Error: No git remotes found" >&2
            return 1
        fi
        remote_url=$(git remote get-url "$first_remote")
    fi

    if [ -z "$remote_url" ]; then
        echo "Error: Could not determine remote URL" >&2
        return 1
    fi

    # Get the directory name
    local dir_name
    dir_name=$(basename "$repo_root")
    
    # Get the parent directory
    local parent_dir
    parent_dir=$(dirname "$repo_root")

    # Confirm action
    echo "Repository: $repo_root"
    echo "Remote URL: $remote_url"
    echo "Directory: $dir_name"
    echo "Parent: $parent_dir"
    echo ""
    echo "WARNING: This will DELETE the entire repository directory and re-clone it."
    echo "All uncommitted changes will be lost!"
    echo ""
    echo -n "Are you sure you want to continue? (yes/no): "
    read confirm

    if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        return 1
    fi

    # Navigate to parent directory
    cd "$parent_dir" || {
        echo "Error: Could not navigate to parent directory: $parent_dir" >&2
        return 1
    }

    # Remove the repository directory
    echo "Removing repository directory..."
    rm -rf "$dir_name" || {
        echo "Error: Could not remove repository directory" >&2
        return 1
    }

    # Clone the repository back
    echo "Cloning repository..."
    git clone "$remote_url" "$dir_name" || {
        echo "Error: Could not clone repository" >&2
        return 1
    }

    # Navigate into the cloned repository
    cd "$dir_name" || {
        echo "Error: Could not navigate into cloned repository" >&2
        return 1
    }

    echo "Done! Repository has been nuked and re-cloned."
    echo "Current directory: $(pwd)"
}
