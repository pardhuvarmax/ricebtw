{ config, pkgs, ... }:

{
  # Phase 4: Go, Rust/Cargo, Node/npm, Python/pipx, CMake, Ninja, LLVM, GDB.
  # (GitHub CLI already migrated in Phase 1 as `gh`.)
  #
  # python/nodejs/ninja/gdb/llvm/clang stay dual-installed on purpose: pacman's
  # copies are hard-required by system packages (python: ~90 incl. reflector,
  # kitty, meson; nodejs/npm: zed; ninja: meson; gdb: debugedit) -- same tier
  # of "never remove" as zsh/git, just not called out by name in the original list.
  home.packages = with pkgs; [
    go
    cmake
    ninja
    gdb
    llvm
    clang
    nodejs
    python3
    # Upstream test suite bug in this nixpkgs snapshot: tests/test_inject.py has a
    # pytest parametrize arg-count mismatch, unrelated to pipx's actual runtime behavior.
    # The test run is gated by doInstallCheck (not doCheck) for this package.
    (pipx.overrideAttrs (old: { doInstallCheck = false; }))
    rustup # replaces pacman's rustup; same ~/.rustup and ~/.cargo, zero migration needed
  ];
}
