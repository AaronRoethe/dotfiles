alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias ghec='gh --hostname github.com'
alias zshrc="code ~/mac_bootstrap/config.code-workspace"
alias c="code ."
alias rf="clear && source $HOME/.zshrc"
alias rp="cd $HOME/repos"
alias myIp="curl api.ipify.org && echo '\n'`ipconfig getifaddr en0`"

addConfig () {
    for file in `config status -s | awk '{print $2}'`; do
        config add $file
    done
    config status
}

showConfigChanges () {
    config diff --cached
}

rms-tools() {
  local KUBE_CONTEXT=$1
  if [ -z "$KUBE_CONTEXT" ]; then
    echo "Select a kube context:"
    contexts=($(kubectl config get-contexts -o name))
    local OLD_COLUMNS=$COLUMNS
    COLUMNS=1
    select ctx in "${contexts[@]}"; do
      if [[ -n "$ctx" ]]; then
        echo "You selected option $REPLY: $ctx"
        KUBE_CONTEXT=$ctx
        break
      else
        echo "Invalid selection. Try again."
      fi
    done
    COLUMNS=$OLD_COLUMNS
  fi
  echo "Using context: $KUBE_CONTEXT"
  local RMS_TOOLS_POD=$(kubectl --context "$KUBE_CONTEXT" -n rms get pods -l app=tools -o go-template='{{ index .items 0 "metadata" "name" }}')
  if [ -z "$RMS_TOOLS_POD" ]; then
    echo "No tools pod found in context $KUBE_CONTEXT"
    return 1
  fi
  echo "Found tools pod: $RMS_TOOLS_POD"
  kubectl --context "$KUBE_CONTEXT" -n rms exec -it "$RMS_TOOLS_POD" -- /bin/bash
}

connect-to-db() {
  local KUBE_CONTEXT=$1

  # If no context provided, prompt user to select one
  if [ -z "$KUBE_CONTEXT" ]; then
    echo "Select a kube context:"
    contexts=($(kubectl config get-contexts -o name))
    local OLD_COLUMNS=$COLUMNS
    COLUMNS=1
    select ctx in "${contexts[@]}"; do
      if [[ -n "$ctx" ]]; then
        echo "You selected option $REPLY: $ctx"
        KUBE_CONTEXT=$ctx
        break
      else
        echo "Invalid selection. Try again."
      fi
    done
    COLUMNS=$OLD_COLUMNS
  fi

  echo "Using context: $KUBE_CONTEXT"

  # Find the tools pod
  local RMS_TOOLS_POD=$(kubectl --context "$KUBE_CONTEXT" -n rms get pods -l app=tools -o go-template='{{ index .items 0 "metadata" "name" }}')
  if [ -z "$RMS_TOOLS_POD" ]; then
    echo "ERROR: No tools pod found in context $KUBE_CONTEXT"
    return 1
  fi

  echo "✓ Found tools pod: $RMS_TOOLS_POD"
  echo ""
  echo "Connecting to integrations database..."
  echo "=========================================="
  echo ""

  # Use the integrations.cnf config file that exists in the pod
  kubectl --context "$KUBE_CONTEXT" -n rms exec -it "$RMS_TOOLS_POD" -- mysql --defaults-extra-file=config/mysql/integrations.cnf integrations
}