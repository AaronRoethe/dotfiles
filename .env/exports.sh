export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

export GOPATH="$HOME/repos/go"
export GOROOT="$(brew --prefix go)/libexec"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$GOROOT/bin"

export DOTNET_ROOT=$HOME/dotnet
export PATH=$PATH:$HOME/dotnet

export PATH=$PATH:$HOME/terraform

# gpg git commit fix
export GPG_TTY=$(tty)