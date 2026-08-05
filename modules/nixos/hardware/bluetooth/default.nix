{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysSpec.hardware.bluetooth;
in
{
  options.sysSpec.hardware.bluetooth = {
    enable = lib.mkEnableOption "Enable bluetooth module";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
      package = pkgs.bluez5-experimental;
      settings = {
        General = {
          # battery info for bluetooth devices
          Experimental = true;
        };
      };
    };
    environment.systemPackages = [ pkgs.blueman ];
  };
}
