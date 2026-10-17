{
  flake.nixosModules.scriptsCiNotify =
    { host, pkgs, ... }:
    let
      script = pkgs.writeShellScriptBin "ci-notify" ''
        set -euo pipefail

        if ! gh auth status &>/dev/null; then
          notify-send -u critical "gh not authenticated" "ci-notify can't check CI status — run 'gh auth login'"
          exit 0
        fi

        conclusion=$(gh run list --repo rmanl/dotfiles --workflow check.yml --limit 1 --json conclusion --jq '.[0].conclusion')
        if [ "$conclusion" = "failure" ]; then
          notify-send -u critical "CI check failed" "nix flake check failed — run 'gh run view -R rmanl/dotfiles' for details"
        fi
      '';
    in
    {
      hjem.users.${host.userName} = {
        packages = [
          script
          pkgs.gh
        ];
        systemd.services."ci-notify" = {
          wantedBy = [ "default.target" ];
          serviceConfig.Type = "oneshot";
          script = "${script}/bin/ci-notify";
        };
      };
    };
}
