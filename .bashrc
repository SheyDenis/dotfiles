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

PS1='[\u@\h \W]\$ '

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# complete
# -c commands
# -f filenames
# -d directories
complete -c man which whereis

# MOTD
#cat /etc/MOTD

if [ $(( RANDOM % 10 )) -ge 5 ]; then
	cowfortune
else
	fortune
fi

HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend

