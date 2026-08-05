{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.apps.media.common;
in
{
  options.homeSpec.apps.media.common = {
    enable = lib.mkEnableOption "Enable common media module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName} = {
      packages = with pkgs; [
        feh
        mpv
        mpvScripts.modernz
        mpvScripts.sponsorblock-minimal
        mpvScripts.thumbfast
      ];

      files.".config/mpv/mpv.conf".text = ''
        fullscreen=yes
        ytdl-format=bestvideo+bestaudio/best
        script=${pkgs.mpvScripts.modernz}/share/mpv/scripts/modernz.lua
        script=${pkgs.mpvScripts.sponsorblock-minimal}/share/mpv/scripts/sponsorblock_minimal.lua
        script=${pkgs.mpvScripts.thumbfast}/share/mpv/scripts/thumbfast.lua
        script=${pkgs.mpvScripts.mpris}/share/mpv/scripts/mpris.lua
      '';
    };
  };
}
