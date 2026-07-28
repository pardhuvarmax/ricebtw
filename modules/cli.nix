{ config, pkgs, ... }:

{
  # Phase 1: CLI utilities (bat, eza, fd, ripgrep, fzf, jq, btop, fastfetch, lazygit, gh, direnv, atuin).
  # Plain packages for now; aliases/shell hooks/theming land together in Phase 3 and Phase 7.
  home.packages = with pkgs; [
    eza
    fd
    ripgrep
    fzf # pacman fzf stays installed too (fzf-tab-git hard-depends on it); this just shadows it on PATH
    jq # pacman jq stays installed too (yq hard-depends on it)
    btop
    fastfetch
    lazygit
    gh
    direnv
    atuin

    # Leaf tools swept in later: verified via `pacman -Qi` that nothing on
    # pacman requires any of these (all "Required By: None"), so plain
    # migration candidates -- no dual-install caveat needed.
    zellij
    yazi
    zoxide
    yt-dlp
    ncdu
    cloc
    bc
    socat
    pv
    tree-sitter
    cbonsai
    asciiquarium
    gum
    tty-clock
    ttyper
    p7zip # pacman package is "7zip"; nixpkgs attribute is "p7zip"
    inotify-tools
    w3m
    lynx
    mpc # MPD CLI client; nixpkgs renamed mpc-cli -> mpc
    rmpc
    wev
    wtype
    wmctrl
  ];

  programs.bat = {
    enable = true;
    # Mirrors the existing BAT_THEME=base16 from .zshrc, written into
    # ~/.config/bat/config so it applies even outside the shell (editors, fzf-tab).
    config = {
      theme = "base16";
    };
  };
}
