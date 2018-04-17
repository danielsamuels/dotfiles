#! /usr/local/bin/bash
PATH="/usr/local/opt/curl/bin:$HOME/.yarn/bin:/usr/local/bin:/usr/local/sbin:$PATH:~/Workspace/_other/scripts/src/bin:/usr/local/mysql/bin"

# Source various helper scripts.
source $HOME/.secrets
# source $HOME/.bashrc
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

. /usr/local/etc/profile.d/z.sh

# NVM
export NVM_DIR="/Users/danielsamuels/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

GEM_HOME="$HOME/.gems"

# Activate virtualenvs when changing into directories.
_virtualenv_auto_activate() {
    if [ -e ".venv" ]; then
        # Check to see if already activated to avoid redundant activating
        if [ "$VIRTUAL_ENV" != "$(pwd -P)/.venv" ]; then
            _VENV_NAME=$(basename `pwd`)
            echo "Activating virtualenv \"$_VENV_NAME\"..."
            VIRTUAL_ENV_DISABLE_PROMPT=1
            source .venv/bin/activate
            _OLD_VIRTUAL_PS1="$PS1"
            PS1="($_VENV_NAME) $PS1"
            export PS1
        fi
    fi
}

_nvm_auto_activate() {
    if [ -f ".nvmrc" ]; then
        if [ $(nvm version `cat .nvmrc` ) != $( nvm current ) ]; then
            nvm use
        fi
    fi
}

# Maintain history across multiple terminal windows.
export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it
export CLICOLOR=1
export TERM=xterm-256color
export EDITOR=nano
export PYTHONDONTWRITEBYTECODE=1

shopt -s globstar
shopt -s dirspell
# shopt -s direxpand

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; _virtualenv_auto_activate; _nvm_auto_activate"

# Path definitions.
export GOPATH=~/Workspace/personal/go
export PATH=$PATH:$GOPATH/bin

# Key-saving aliases.
alias p='git pp'
alias virtualenv='/usr/local/bin/virtualenv -p python'
alias fuck='$(thefuck $(fc -ln -1))'
alias pf='pip freeze > requirements.txt'
alias pi='pip install --upgrade pip; pip install -r requirements.txt'
alias publish='python setup.py register sdist upload'
alias i='ghi open -u danielsamuels'
alias iw='watch -n 5 ghi list -S updated'
alias n='while true; do npm run dev; done'
alias fix-npm='rm -rf node_modules; yarn'
alias c="clear && printf '\e[3J'"
# For now..
alias sublime=code
alias c='code .'

# Project up to date
u() {
  git pull
  pip install --upgrade pip
  pip install -r requirements.txt
  yarn
  python manage.py pulldb
  python manage.py pullmedia
  runserver
}

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Does staging use the same IP as production?
sameip() {
    if [ "$(dig +short "$1")" == "$(dig +short "$2")" ]; then
        echo 'True';
    else
        echo 'False';
    fi;
}

# Easily switch between `io.js` and `Node.js`
alias use-node-012="brew unlink node && brew link node012"
alias use-node="brew unlink node012 && brew link node"

# Ring the terminal bell, and put a badge on Terminal.app’s Dock icon
# (useful when executing time-consuming commands)
alias badge="tput bel"

shell_plus() {
    PROJECT_FOLDER=$(basename $( find . -name 'wsgi.py' -not -path '*/.venv/*' -not -path '*/venv/*' | xargs -0 -n1 dirname ))
    ssh -t deploy@$PROJECT_FOLDER.onespace.media "sudo -u $PROJECT_FOLDER /var/www/$PROJECT_FOLDER/.venv/bin/python /var/www/$PROJECT_FOLDER/manage.py shell_plus --settings=$PROJECT_FOLDER.settings.production"
}

m(){
    python manage.py migrate "$@"
}

mm(){
    if pip --disable-pip-version-check freeze | grep -q South > /dev/null 2>&1; then
      python manage.py schemamigration $1 --au
    else
      python manage.py makemigrations "$@"
    fi
}

mmm(){
    mm "$@"
    m "$@"
}

runtest(){
    export SKIP_SELENIUM_TESTS=1
    rm -rf htmlcov/
    coverage run --source=moneymover --omit=*migrations* manage.py test "$1"
    coverage html
}

runserver(){
    while true; do python manage.py runserver_plus 0.0.0.0:${1:-8000} --threaded "${@:2}"; sleep 3; done
}

mov2gif() {
    if [ $# -eq 0 ]; then
        echo "Usage: mov2gif <file> <fps:30> <scale:0.4>"
        return 1
    fi
    # 0.5 for downscaling retina
    SCALE=${3:-0.4}
    ffmpeg -y -i $1 -vf fps=${2:30},scale=iw*$SCALE:ih*$SCALE,palettegen palette.png
    ffmpeg -i $1 -i palette.png -filter_complex "fps=${2:30},scale=iw*$SCALE:ih*$SCALE,paletteuse" $1.gif
    open -R $1.gif
}

rpl() {
    # Fully clear the buffer.
    clear && printf '\e[3J'
    cd ~/Workspace/personal/rocket-league/rocket-league-replays/
    . .venv/bin/activate
    echo "r = Replay.objects.get(pk=${1}); r.processed = False; r.crashed_heatmap_parser = False; r.save(parse_netstream=True)" | python -q manage.py shell_plus --quiet-load
}

mmfile() {
    IMAGE_DATA="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="
    mkdir -p $1
    rmdir $1
    echo $IMAGE_DATA | base64 --decode > $1
}

# Code search
# Usage: s "DecimalField"
s() {
    ag -Q --ignore "-htmlcov/*,-js/build/*,-migrations/*,-*.svg,-build/*.css,-static/css/*.css,-.venv/*,-build/*,-static/js/*.js.map,-static/js/app.js,-.git/*,-node_modules/*,-tests/*.py,-*.min.js,-ckeditor/*,-frontend/*,-static/css/*,-ui-kit/*,-*.csv,-*.log,-*.xml,-*.json" "$1" ~/Workspace/
}

addsshkey() (  # Regular brackets to turn this into a subshell
    shopt -s nocasematch

    case "$1" in
        "dg")
            USER='dan-gamble'
            ;;
        "dc")
            USER='daniel-clayton'
            ;;
        "ds")
            USER='daniel-samuels'
            ;;
        "eh")
            USER='eik-hunter'
            ;;
        "jf")
            USER='james-foley'
            ;;
        "lc")
            USER='lewis-collard'
            ;;
        "tr")
            USER='thomas-rumbold'
            ;;
        *)
            echo 'Invalid person specified'
            exit
            ;;
    esac

    SSH_KEY=$(cat ~/Documents/ssh-keys/$USER.pub)

    echo "$SSH_KEY" | ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "deploy@$2.onespace.media" "cat >> /home/deploy/.ssh/authorized_keys"
    echo "SSH key for $USER has been added to $2.onespace.media."
)

venv() {
    PYTHON_2_COMMAND="/usr/local/bin/virtualenv -p python .venv"
    PYTHON_3_COMMAND="/usr/local/bin/python3 -m venv .venv"

    # Was the Python version defined in the args?
    if [ -z "$1" ]; then
        # Try to read the Django version from the requirements
        DJANGO_VERSION=(`grep '^Django' requirements.txt | python -c 'import sys; req = sys.stdin.read().strip(); print(req.split(".")[1])'`)

        if (( DJANGO_VERSION > 10 )); then
            echo "Creating a Python 3 virtual environment (read Django version > 10)."
            eval "$PYTHON_3_COMMAND"
        else
            echo "Creating a Python 2 virtual environment (read Django version <= 10)."
            eval "$PYTHON_2_COMMAND"
        fi
    else
        if [ "${1:2}" == 2 ]; then  # Python 2 venv
            echo "Creating a Python 2 virtual environment (manually specified as 2)."
            eval "$PYTHON_2_COMMAND"
        elif [ "$1" == 3 ]; then
            echo "Creating a Python 3 virtual environment (manually specified as 3)."
            eval "$PYTHON_3_COMMAND"
        fi
    fi

    source .venv/bin/activate
    pip install -U setuptools pip
    pip install -r requirements.txt
}

lnk() {
    FOLDER=${1%/}
    LETTER=${FOLDER:0:1}
    ln -s /Users/danielsamuels/Workspace/_client-projects/"$LETTER"/"$FOLDER"/ /Users/danielsamuels/Workspace/"$FOLDER"
}

worker() {
    DB_USER=$(whoami) DB_NAME="$1" DJANGO_SETTINGS_MODULE="$1.settings.local" celery -A "$1" worker -E --loglevel="${2:-info}"
}

quickrelease() {
    git flow release start "$1"
    git flow release finish -m "$1" "$1"
    git push --all
}
