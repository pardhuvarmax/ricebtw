{ config, pkgs, ... }:

{
  # Phase 6: GUI applications.
  #
  # firefox, brave, obsidian, mpv deliberately NOT here: Nix's bundled Mesa
  # can't reach Arch's real GPU driver stack cleanly (the /run/opengl-driver
  # symlink fixes the first hop, but nested dependencies like libgallium hit
  # a hard glibc-ABI wall via LD_LIBRARY_PATH -- tested and rejected, see
  # commit history). These stay pacman-only permanently, same tier as
  # python/nodejs from Phase 4. Revisit only if nixGL gets set up properly.
  #
  # flameshot verified clean (no GPU/EGL errors, doesn't need heavy GL
  # compositing the way Electron/Chromium apps do) -- migrated normally.
  home.packages = with pkgs; [
    flameshot
  ];
}
