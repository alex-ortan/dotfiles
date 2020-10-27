# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -lh'
alias la='ls -Alh'

# Alias for side-folder git for dotfile management
# https://www.atlassian.com/git/tutorials/dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.cfg-git/ --work-tree=$HOME'

# Shortcuts for finding files
function f {
  find . -type f | grep -v .svn | grep -v .git | grep -i $1
}

