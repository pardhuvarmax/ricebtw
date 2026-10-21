# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

[ -f ~/.aliases ] && . ~/.aliases

alias music='rmpc'
alias vim='nvim'
alias mysql='mysql -u root -p'
alias linutil='curl -fsSL https://christitus.com/linux | sh'
command -v zoxide >/dev/null && eval "$(zoxide init bash)"

ff() {
    if [[ "$1" == "-n" ]]; then
        fastfetch --logo-type file --logo "$(find ~/.config/fastfetch/ascii -type f 2>/dev/null | shuf -n1)"
    else
        fastfetch
    fi
}

# show system info on every new interactive terminal
command -v fastfetch >/dev/null && fastfetch
