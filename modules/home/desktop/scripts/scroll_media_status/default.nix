{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.desktop.scripts.scroll_media_status;
  scroll_media_status = pkgs.writeShellScriptBin "scroll_media_status" ''
     # https://github.com/noctuid/zscroll
     # see man zscroll for documentation of the following parameters
     # use mono style font for scroll
    ${lib.getExe pkgs.zscroll} -l 20 \
     --delay 0.1 \
     --scroll-padding " " \
     --match-command "$(dirname "$0")/media_status --status" \
     --match-text "Playing" "--scroll 1" \
     --match-text "Paused" "--scroll 0" \
     --update-check true "$(dirname "$0")/media_status" &

     wait
  '';
in
{
  options.homeSpec.desktop.scripts.scroll_media_status = {
    enable = lib.mkEnableOption "Enable scroll_media_status script";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = [ scroll_media_status ];
  };
}
