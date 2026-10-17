{
  flake.nixosModules.mediaCommon =
    { host, pkgs, ... }:
    let
      inherit (pkgs.mpvScripts)
        modernz
        sponsorblock-minimal
        thumbfast
        mpris
        ;
    in
    {
      hjem.users.${host.userName} = {
        packages = with pkgs; [
          imv
          mpv
          modernz
          sponsorblock-minimal
          thumbfast
        ];

        files.".config/mpv/mpv.conf".text = ''
          fullscreen=yes
          hwdec=auto
          ytdl-format=bestvideo+bestaudio/best
          script=${modernz}/share/mpv/scripts/modernz.lua
          script=${sponsorblock-minimal}/share/mpv/scripts/sponsorblock_minimal.lua
          script=${thumbfast}/share/mpv/scripts/thumbfast.lua
          script=${mpris}/share/mpv/scripts/mpris.lua
        '';
      };
    };
}
