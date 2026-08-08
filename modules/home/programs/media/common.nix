{
  flake.nixosModules.mediaCommon =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName} = {
        packages = with pkgs; [
          feh
          mpv
          mpvScripts.modernz
          mpvScripts.sponsorblock-minimal
          mpvScripts.thumbfast
        ];

        files.".config/mpv/mpv.conf".text = ''
          fullscreen=yes
          hwdec=auto
          ytdl-format=bestvideo+bestaudio/best
          script=${pkgs.mpvScripts.modernz}/share/mpv/scripts/modernz.lua
          script=${pkgs.mpvScripts.sponsorblock-minimal}/share/mpv/scripts/sponsorblock_minimal.lua
          script=${pkgs.mpvScripts.thumbfast}/share/mpv/scripts/thumbfast.lua
          script=${pkgs.mpvScripts.mpris}/share/mpv/scripts/mpris.lua
        '';
      };
    };
}
