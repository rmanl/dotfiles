{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.system.network;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.sysSpec.system.network = {
    enable = lib.mkEnableOption "Enable network modules";
  };

  config = lib.mkIf cfg.enable {
    sysSpec.system.network = {
      avahi.enable = true;
      openssh.enable = true;
      settings.enable = true;
      unbound.enable = true;
    };
  };
}
