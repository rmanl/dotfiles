{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.gaming;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.homeSpec.gaming = {
    enable = lib.mkEnableOption "Enable gaming modules";
  };

  config = lib.mkIf cfg.enable {
    homeSpec.gaming = {
      gamemode.enable = true;
      gamescope.enable = true;
      hardware.enable = true;
      misc.enable = true;
      steam.enable = true;
    };
  };
}
