{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysSpec.services.udisks;
in
{
  options.sysSpec.services.udisks = {
    enable = lib.mkEnableOption "Enable udisks module";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.udiskie ];
    services = {
      dbus.packages = [ pkgs.udisks2 ];
      udisks2.enable = true;
    };
  };
}
