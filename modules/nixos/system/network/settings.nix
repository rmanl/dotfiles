{
  flake.nixosModules.networkSettings =
    { host, pkgs, ... }:
    let
      inherit (host) userName isLaptop hostName;
    in
    {
      users.users.${userName}.extraGroups = [
        "networkmanager"
      ];

      networking = {
        inherit hostName;
        useDHCP = false;
        networkmanager = {
          enable = true;
          wifi.powersave = isLaptop;
        };
      };

      systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart = [
        ""
        "${pkgs.networkmanager}/bin/nm-online -q"
      ];

      environment.systemPackages = [
        pkgs.networkmanagerapplet
      ];
    };
}
