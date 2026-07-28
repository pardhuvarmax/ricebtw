{ config, pkgs, lib, ... }:

{
  # Phase 3: zsh core config, history, completion, Powerlevel10k, env vars.
  # Aliases live in ./aliases.nix. direnv/atuin shell hooks intentionally NOT
  # wired yet -- binaries are installed (Phase 1) but the hooks weren't active
  # in the original .zshrc, so enabling them is new behavior, deferred.
  home.packages = [ pkgs.zsh-powerlevel10k ];

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "/opt/java/jdk-25.0.3+9/bin"
    "/home/texlive/2026/bin/x86_64-linux"
    "/home/sicmundus/.spicetify"
  ];

  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # searchUpKey/searchDownKey default to ^[[A/^[[B, matching the original bindkeys exactly.
    historySubstringSearch.enable = true;

    history = {
      path = "$HOME/.config/zsh/zhistory";
      size = 5000;
      save = 5000;
      append = true; # matches original `setopt appendhistory`
      ignoreDups = true;
      ignoreAllDups = true;
      saveNoDups = true;
      findNoDups = true;
      ignoreSpace = true;
      share = true;
    };

    # Custom compinit with zcompdump caching + zcompile, replacing the module's
    # plain "compinit" default -- this is the user's existing startup-speed optimization.
    completionInit = ''
      autoload -Uz compinit

      local zcompdump="$HOME/.config/zsh/zcompdump"

      if [[ -n "$zcompdump"(#qN.mh+24) ]]; then
          compinit -i -d "$zcompdump"
      else
          compinit -C -d "$zcompdump"
      fi

      if [[ ! -f "''${zcompdump}.zwc" || "$zcompdump" -nt "''${zcompdump}.zwc" ]]; then
          zcompile -U "$zcompdump"
      fi
    '';

    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];

    sessionVariables = {
      EDITOR = "geany";
      VISUAL = "geany";
      BROWSER = "brave";
      HISTORY_IGNORE = "(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)";
      SUDO_PROMPT = "Deploying root access for %u. Password pls: ";
      JAVA_HOME = "/opt/java/jdk-25.0.3+9";
      WALLPAPER_DIR = "/home/sicmundus/Pictures/Wallpapers";
      SCRIPT_DIR = "/home/sicmundus/.config/hypr/scripts";
      # BAT_THEME dropped: redundant with programs.bat.config.theme in cli.nix.
    };

    initContent = lib.mkMerge [
      # Must run before anything else, including the interactive-shell check.
      (lib.mkOrder 200 ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi

        [[ $- != *i* ]] && return
      '')

      (lib.mkOrder 900 ''
        autoload -Uz add-zsh-hook
        autoload -Uz vcs_info
        precmd () { vcs_info }
        _comp_options+=(globdots)

        zstyle ':completion:*' menu select
        zstyle ':completion:*:descriptions' format '[%d]'
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
        zstyle ':completion:*' matcher-list \
            'm:{a-zA-Z}={A-Za-z}' \
            '+r:|[._-]=* r:|=*' \
            '+l:|=*'
        zstyle ':vcs_info:*' formats ' %B%s-[%F{magenta}%f %F{yellow}%b%f]-'
        zstyle ':fzf-tab:*' fzf-flags --style=full --height=90% --pointer '>' \
                        --color 'pointer:green:bold,bg+:-1:,fg+:green:bold,info:blue:bold,marker:yellow:bold,hl:gray:bold,hl+:yellow:bold' \
                        --input-label ' Search ' --color 'input-border:blue,input-label:blue:bold' \
                        --list-label ' Results ' --color 'list-border:green,list-label:green:bold' \
                        --preview-label ' Preview ' --color 'preview-border:magenta,preview-label:magenta:bold'
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons=always --color=always -a $realpath'
        zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza -1 --icons=always --color=always -a $realpath'
        zstyle ':fzf-tab:complete:bat:*' fzf-preview 'bat --color=always --theme=base16 $realpath'
        zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
        zstyle ':fzf-tab:*' accept-line enter

        expand-or-complete-with-dots() {
          echo -n "\e[31m…\e[0m"
          zle expand-or-complete
          zle redisplay
        }
        zle -N expand-or-complete-with-dots
        bindkey "^I" expand-or-complete-with-dots

        # history-substring-search up/down already bound by programs.zsh.historySubstringSearch
        bindkey '^[[3~' delete-char
        bindkey "^[[H" beginning-of-line
        bindkey "^[[F" end-of-line

        HISTDUP=erase

        setopt AUTOCD PROMPT_SUBST MENU_COMPLETE LIST_PACKED AUTO_LIST COMPLETE_IN_WORD

        # Legacy custom PS1 -- superseded the moment Powerlevel10k is sourced below
        # (PS1/PROMPT is the same zsh parameter). Kept for exact parity; effectively dead.
        function dir_icon {
          if [[ "$PWD" == "$HOME" ]]; then
            echo "%B%F{cyan}%f%b"
          else
            echo "%B%F{cyan}%f%b"
          fi
        }
        PS1='%B%F{blue}%f%b  %B%F{magenta}%n%f%b $(dir_icon)  %B%F{red}%~%f%b''${vcs_info_msg_0_} %(?.%B%F{green}.%F{red})%f%b '

        function xterm_title_precmd () {
          print -Pn -- '\e]2;%n@%m %~\a'
          [[ "$TERM" == 'screen'* ]] && print -Pn -- '\e_\005{g}%n\005{-}@\005{m}%m\005{-} \005{B}%~\005{-}\e\\'
        }

        function xterm_title_preexec () {
          print -Pn -- '\e]2;%n@%m %~ %# ' && print -n -- "''${(q)1}\a"
          [[ "$TERM" == 'screen'* ]] && { print -Pn -- '\e_\005{g}%n\005{-}@\005{m}%m\005{-} \005{B}%~\005{-} %# ' && print -n -- "''${(q)1}\e\\"; }
        }

        if [[ "$TERM" == (kitty*|alacritty*|tmux*|screen*|xterm*) ]]; then
          add-zsh-hook -Uz precmd xterm_title_precmd
          add-zsh-hook -Uz preexec xterm_title_preexec
        fi

        # ~/.aliases is no longer sourced here -- its full contents (deduped against
        # the old inline .zshrc aliases) now live in programs.zsh.shellAliases (aliases.nix).

        unalias ff 2>/dev/null
        ff() {
            if [[ "$1" == "-n" ]]; then
                poke=$(find ~/.config/fastfetch/ascii -type f | shuf -n1)
                fastfetch --logo-type file --logo "$poke"
            else
                fastfetch
            fi
        }
      '')

      (lib.mkOrder 1500 ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        fastfetch
        eval "$(zoxide init zsh)"

        # Kept verbatim -- restarts this systemd user service on every new interactive shell.
        systemctl --user restart infinite-desktop.service
      '')
    ];
  };
}
