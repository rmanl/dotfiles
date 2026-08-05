{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysSpec.system.network.settings;
  inherit (config.hostSpec) userName isLaptop hostName;
in
{
  options.sysSpec.system.network.settings = {
    enable = lib.mkEnableOption "Enable network settings module";
  };

  config = lib.mkIf cfg.enable {
    users.users.${userName}.extraGroups = [
      "networking"
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
