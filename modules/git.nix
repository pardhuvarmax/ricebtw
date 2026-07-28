{ config, pkgs, ... }:

{
  # Phase 2: programs.git. Mirrors the existing ~/.gitconfig verbatim.
  # pacman's git stays installed regardless -- it's hard-required by
  # paru, yay, git-filter-repo, and zed (same tier as zsh, never removed).
  programs.git = {
    enable = true;
    settings = {
      user.name = "PardhuVarma Konduru";
      user.email = "140948604+pardhuvarmax@users.noreply.github.com";
      core.editor = "nvim";
      credential.helper = "store";
    };
  };
}
