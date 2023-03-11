#!/bin/zsh
FILENAME=$(basename $0)
VENV='.venv'

function usage { cat <<EOF
    Usage: $FILENAME -a (copy, delete, send)

    Description:
        <Fill me>
        Build: sh ./$FILENAME -b

    Options:
        -a, --action      The action to perform on $FILENAME (action1, action2...).

    Example: $FILENAME -a send
EOF
}

function build {
    echo "Remove old exec if available"
    sudo rm -fv /usr/local/bin/$FILENAME
    echo -e "\nCreate executable for $FILENAME"
    # chmod +x $FILENAME
    sudo ln -s $PWD/$FILENAME /usr/local/bin/$FILENAME && echo -e "copy complete\n"
}

while getopts "a:h?:b?" opt; do
  case $opt in
    a) action=$OPTARG;;
    h) usage; exit 1 ;;
    b) build; exit 1 ;;
  esac
done

# Stop if required vars aren't present
[[ -z "$action" ]] && { usage; exit 1; }

function runPython {
    projectPath=$(dirname "$(readlink -f /usr/local/bin/$FILENAME)")
    cd $projectPath
    source "$projectPath/$VENV/bin/activate"

    python app.py -a $action

    deactivate
}
