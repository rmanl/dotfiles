{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.services;
  inherit (config.hostSpec) isLaptop hostName;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.sysSpec.services = {
    enable = lib.mkEnableOption "Enable service modules";
  };

  config = lib.mkIf cfg.enable {
    sysSpec.services = {
      ananicy.enable = true;
      fstrim.enable = true;
      greetd.enable = true;
      power.enable = isLaptop;
      thinkfan.enable = hostName == "ferrix";
      psd.enable = true;
      thermald.enable = hostName == "ferrix";
      udisks.enable = true;
    };
  };
}
