{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.gaming.steam;
in
{
  options.homeSpec.gaming.steam = {
    enable = lib.mkEnableOption "Enable steam module";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = false; # tcp 27036 udp 27036 + 27031-27035
      dedicatedServer.openFirewall = false; # tcp+udp 27015
      localNetworkGameTransfers.openFirewall = false; # tcp 27040 udp 27036
      extraPackages = [ pkgs.capitaine-cursors ];
    };

    hjem.users.${config.hostSpec.userName}.packages = [
      pkgs.steam-run
    ];

    hardware.steam-hardware.enable = true; # controller support
  };
}
