# Setup
`git clone --bare git@github.com:AaronRoethe/dotfiles.git $HOME/.cfg`

or clone from a local friend:

`git clone --bare username@<target-ip>:~/.cfg $HOME/.cfg`

---

`alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'`

`config config --local status.showUntrackedFiles no`

### Warning: this will remove/update existing files to reflect remote
`config restore --staged . && config restore .`

# Run bootstap
`sh mac_bootstrap/bootstrap.sh`
