{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.apps.browsers;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.homeSpec.apps.browsers = {
    enable = lib.mkEnableOption "Enable browsers module";
  };

  config = lib.mkIf cfg.enable {
    homeSpec.apps.browsers = {
      brave.enable = true;
      librewolf.enable = true;
    };
  };
}
