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
