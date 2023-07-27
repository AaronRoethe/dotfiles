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

# Sign commits
[Link](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)

`brew install gpg`

`gpg --full-generate-key`

Pick `RSA and RSA`

`gpg --list-secret-keys --keyid-format=long`

copy command from above after rsa3072/<...>

`gpg --armor --export <paste>`

`git config --global user.signingKey <paste>`

add the output into github

# Mac setting preferences
