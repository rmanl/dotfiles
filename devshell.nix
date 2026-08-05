{
  flake,
  system,
  pkgs,
  ...
}:
let
  preCommit = flake.checks.${system}.git.pre-commit-check;
in
pkgs.mkShellNoCC {
  inherit (preCommit) shellHook;
  NIX_CONFIG = "extra-experimental-features = nix-command flakes";
  BOOTSTRAP_USER = "rma";
  BOOTSTRAP_SSH_PORT = "22";
  BOOTSTRAP_SSH_KEY = "~/.ssh/id_rma";

  packages = with pkgs; [
    deadnix
    git
    just
    lix # package manager
    nh
    pre-commit
    yq-go # jq for yaml, used for build scripts
    age # for bootstrap script
    ripgrep
    ssh-to-age # for bootstrap script
    sops

    preCommit.enabledPackages
  ];
}
