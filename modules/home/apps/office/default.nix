{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.apps.office;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.homeSpec.apps.office = {
    enable = lib.mkEnableOption "Enable office modules";
  };

  config = lib.mkIf cfg.enable {
    homeSpec.apps.office = {
      gimp.enable = true;
      libreoffice.enable = true;
      zathura.enable = true;
    };
  };
}
