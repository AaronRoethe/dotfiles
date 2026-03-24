alias pyA="source .venv/bin/activate" 

pyC () {
    location="requirements.txt"
    venvName=".venv"
    
    # Parse flags
    while getopts "r:e:c:" opt; do
        case $opt in
            e) venvName=$OPTARG ;;
            r) location=$OPTARG ;;
            c) cache=$OPTARG ;;
            \?) echo "Invalid option: -$OPTARG" ;;
            :) echo "Option -$OPTARG requires an argument.";;
        esac
    done

    # Remove existing virtual environment if it exists
    [ -d $venvName ] && rm -rf $venvName

    # Determine Python version (global or local)
    pyVersion=$( [ -f .python-version ] && echo "local" || echo "global" )

    # Check pyVersion, create version file, virtual environment, activate it
    pyenv version-name $pyVersion | xargs -I {} pyenv local {} && python3 -m venv $venvName
    source $venvName/bin/activate && pip install --upgrade pip

    # Install requirements if file exists, otherwise print error message
    [ -f $location ] && pip install --no-cache-dir -r $location || echo -e "\nFile $location not found"
}


