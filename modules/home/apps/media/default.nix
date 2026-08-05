{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.apps.media;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.homeSpec.apps.media = {
    enable = lib.mkEnableOption "Enable media modules";
  };

  config = lib.mkIf cfg.enable {
    homeSpec.apps.media = {
      common.enable = true;
      spotify.enable = true;
    };
  };
}
