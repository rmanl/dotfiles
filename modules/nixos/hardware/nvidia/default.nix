{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.hardware.nvidia;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.sysSpec.hardware.nvidia = {
    enable = lib.mkEnableOption "Enable nvidia modules";
  };

  config = lib.mkIf cfg.enable {
    sysSpec.hardware.nvidia = {
      fancontrol.enable = true;
      opengl.enable = true;
      settings.enable = true;
      vaapi.enable = true;
    };
  };
}
