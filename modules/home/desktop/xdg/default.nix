{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.desktop.xdg;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.homeSpec.desktop.xdg = {
    enable = lib.mkEnableOption "Enable system xdg modules";
  };

  config = lib.mkIf cfg.enable {
    homeSpec.desktop.xdg = {
      dirs.enable = true;
      env.enable = true;
      mime.enable = true;
      portal.enable = true;
    };
  };
}
