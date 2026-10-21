# Commands to run in interactive sessions can go here
if status is-interactive
    # No greeting
    set fish_greeting

    # fasfetch 
    fastfetch

    # Use starship
    function starship_transient_prompt_func
        starship module character
    end
    if test "$TERM" != "linux"
        starship init fish | source
        enable_transience
    end
    
    # Colors
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Aliases
    # kitty doesn't clear properly so we need to do this weird printing
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias pamcan pacman
    alias q 'qs -c ii'
    if test "$TERM" != "linux"
        alias ls 'eza --icons'
    end
    if test "$TERM" = "xterm-kitty"
        alias ssh 'kitten ssh'
    end
end
# 1. Load the alias file
if test -f ~/.config/fish/aliases.conf
    source ~/.config/fish/aliases.conf
end

# 2. Initialize Modern Tools (Must be at the bottom)
zoxide init fish | source    # Enables 'z' and 'cd' logic
atuin init fish | source     # Enables the fancy history search
direnv hook fish | source    # Automatically loads Nix/Venv when you cd

function ff
    set file (ls ~/.config/fastfetch/ascii | shuf -n 1)
    fastfetch --logo-type file --logo ~/.config/fastfetch/ascii/$file $argv
end


# Added by Antigravity CLI installer
set -gx PATH "/home/sicmundus/.local/bin" $PATH
