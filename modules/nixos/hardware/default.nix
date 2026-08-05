{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.hardware;
  inherit (config.hostSpec) isLaptop isNvidia;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.sysSpec.hardware = {
    enable = lib.mkEnableOption "Enable hardware modules";
  };

  config = lib.mkIf cfg.enable {
    sysSpec.hardware = {
      backlight.enable = isLaptop;
      bluetooth.enable = true;
      fwupd.enable = true;
      nvidia.enable = isNvidia;
      pipewire.enable = true;
    };
  };
}
