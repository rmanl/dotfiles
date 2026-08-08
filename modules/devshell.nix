{
  perSystem =
    { pkgs, config, ... }:
    let
      preCommit = config.checks.pre-commit-check;
    in
    {
      devShells.default = pkgs.mkShellNoCC {
        inherit (preCommit) shellHook;
        NIX_CONFIG = "extra-experimental-features = nix-command flakes";

        packages =
          with pkgs;
          [
            deadnix
            git
            just
            lix
            nh
            pre-commit
            yq-go
            age
            ripgrep
            ssh-to-age
            sops
          ]
          ++ preCommit.enabledPackages;
      };
    };
}
