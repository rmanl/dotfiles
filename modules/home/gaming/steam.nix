{
  flake.nixosModules.gamingSteam =
    { host, pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = false; # tcp 27036 udp 27036 + 27031-27035
        dedicatedServer.openFirewall = false; # tcp+udp 27015
        localNetworkGameTransfers.openFirewall = false; # tcp 27040 udp 27036
        extraPackages = [ pkgs.capitaine-cursors ];
      };

      hjem.users.${host.userName}.packages = [ pkgs.steam-run ];

      hardware.steam-hardware.enable = true; # controller support
    };
}
