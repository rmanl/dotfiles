{
  flake.nixosModules.scriptsColorpick =
    {
      host,
      pkgs,
      config,
      ...
    }:
    let
      # pinned to an unreleased commit that fixes a screencopy bug on mango,
      # see "Hyprpicker nixpkgs pin" in CLAUDE.md for details and removal steps.
      hyprpickerFixed = pkgs.hyprpicker.overrideAttrs (old: {
        version = "unstable-2026-09-01";
        src = pkgs.fetchFromGitHub {
          owner = "hyprwm";
          repo = "hyprpicker";
          rev = "5c451cb4e9d6b1bd2f729d68de8aa114112c7390";
          hash = "sha256-KtzKVSHzXuM6YW/yPZQ8OFHL8ZzSWAT3Y770KOAixWE=";
        };
      });

      colorpick = pkgs.writeShellScriptBin "colorpick" ''
        set -euo pipefail

        pkill -x hyprpicker && exit 0

        hex=$(${hyprpickerFixed}/bin/hyprpicker -a) || exit 0
        [[ -z "$hex" ]] && exit 0

        swatch=$(mktemp --suffix=.png)
        trap 'rm -f "$swatch"' EXIT

        ${pkgs.imagemagick}/bin/magick -size 62x62 "xc:$hex" -bordercolor "${config.colors.withHashtag.base0B}" -border 1 "$swatch"
        notify-send -u normal -t 2000 -a "Color Picker" -i "$swatch" "$hex"
      '';
    in
    {
      hjem.users.${host.userName}.packages = [ colorpick ];
    };
}
