{ config, pkgs, ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/cli.nix
    ./modules/git.nix
    ./modules/shell.nix
    ./modules/aliases.nix
    ./modules/dev.nix
    ./modules/secrets.nix
    ./modules/editors.nix
    ./modules/gui.nix
  ];

  home.username = "sicmundus";
  home.homeDirectory = "/home/sicmundus";

  # Pinned to the Home Manager release this config was created against.
  # Do not bump without reading the release notes for breaking changes.
  home.stateVersion = "26.05";

  # Let Home Manager manage itself (adds the `home-manager` command to the profile).
  programs.home-manager.enable = true;
}
