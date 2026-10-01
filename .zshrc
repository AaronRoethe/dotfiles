# Warp provides prompt, completions, and autosuggestions, so no framework here.
# Sources every ~/.env/*.sh, including untracked local.sh / work.sh if present.
for config in $HOME/.env/*.sh; do
    source "$config"
done
