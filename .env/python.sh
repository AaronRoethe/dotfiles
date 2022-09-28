export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

alias pyActivate="source .venv/bin/activate" 

pyCreate () {
	if [ -d .venv ];then 
	    rm -rf .venv; fi &&
	
	if [ -f .python-version ];then
	    pyVersion="local"
	else
	    pyVersion="global"; fi &&

	location=${1:-requirements.txt} &&

	if [ -f $location ];then
	    action=(pip install -r $location)
	else
	    action=(echo "\n No file: $location \n"); fi &&	

	PYENV_VERSION=`pyenv $pyVersion` python -m venv .venv &&
	source .venv/bin/activate &&
	pip install --upgrade pip && $action
}

