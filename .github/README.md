# Setup
`git clone --bare https://github.com/AaronRoethe/dotfiles.git $HOME/.cfg`

`alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'`

`config config --local status.showUntrackedFiles no`

# warning: this will remove/update existing files to reflect remote
`config restore --staged . && config restore .`

# Run bootstap
`sh mac_bootstrap/bootstrap.sh`
