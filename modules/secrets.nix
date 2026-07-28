{ inputs, pkgs, ... }:

{
  imports = [ inputs.agenix.homeManagerModules.default ];

  # age.identityPaths defaults to ~/.ssh/id_ed25519 (and id_rsa), which already
  # matches the key you have -- no override needed.
  #
  # age.secrets.<name> = { file = ../secrets/foo.age; }; decrypts at activation
  # via a systemd user service into ~/.local/share/agenix (or wherever `path`
  # points). Recipients for a given secret are declared in secrets/secrets.nix
  # (gitignored -- it's not secret, just kept off the public repo; recreate it
  # locally from ~/.ssh/id_ed25519.pub if this repo is ever cloned fresh),
  # which the `agenix` CLI below reads when you encrypt/edit a file:
  #
  #   agenix -e secrets/foo.age
  #
  # Nothing is defined yet -- this only stops being a no-op once age.secrets
  # gets its first entry.
  home.packages = [ inputs.agenix.packages.${pkgs.system}.default ];
}
