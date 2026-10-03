{
  flake.nixosModules.scriptsCliphist =
    { host, pkgs, ... }:
    let
      clipmenu = pkgs.writeShellScriptBin "clipmenu" ''
        set -euo pipefail

        selected=$(cliphist list | fuzzel -d -l 10 -p "Clipboard: ") || exit 0
        [[ -z "$selected" ]] && exit 0

        echo "$selected" | cliphist decode | wl-copy
      '';
    in
    {
      hjem.users.${host.userName}.packages = with pkgs; [
        clipmenu
        cliphist
      ];
    };
}
