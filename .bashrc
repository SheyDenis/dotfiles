#
# ~/.bashrc
#

PATH+=":/home/${USER}/.local/scripts/"

for file in ~/.{aliases,functions,profile}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Start tmux on login shell
shopt -q login_shell && [ -z "$TMUX" ] && exec tmux

PS1='[${?}][\u@\h \W]\$ '

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# complete
# -c commands
# -f filenames
# -d directories
complete -c man which whereis

# MOTD
#cat /etc/MOTD
fortune -o

export HISTSIZE=5000
export HISTFILESIZE=10000
export HISTCONTROL=ignoreboth # ignorespace:ignoredups:ignoreboth:erasedups
export HISTTIMEFORMAT='[%Y-%m-%d %H:%M:%S] '
shopt -s histappend

set -o noclobber

