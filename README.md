# Run bootstap
`git clone --bare https://github.com/AaronRoethe/dotfiles.git $HOME/.cfg`

`sh mac_bootstrap/bootstrap.sh`

# Setup .zshrc

`alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'`

`config config --local status.showUntrackedFiles no`

`config restore --staged . && config restore .`
