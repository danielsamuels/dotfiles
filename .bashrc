
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
HISTFILE="${HOME}/.history/$(date -u +%Y/%m/%d.%H.%M.%S)_${HOSTNAME_SHORT}_$$"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"


export NVM_DIR="/Users/danielsamuels/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

export PATH="$HOME/.yarn/bin:$PATH"


# added by travis gem
[ -f /Users/danielsamuels/.travis/travis.sh ] && source /Users/danielsamuels/.travis/travis.sh

. /usr/local/etc/profile.d/z.sh
