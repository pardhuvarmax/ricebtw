{ config, pkgs, ... }:

{
  # Phase 5: Neovim. Just the binary -- ~/.config/nvim is a self-managed
  # lazy.nvim setup (git-bootstrapped, own lockfile, mason-installed LSP
  # servers under ~/.local/share/nvim). Nix has no business managing any
  # of that; it would only fight lazy.nvim for no benefit.
  home.packages = [ pkgs.neovim ];
}
