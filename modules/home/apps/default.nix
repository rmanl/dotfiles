{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.apps;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.homeSpec.apps = {
    enable = lib.mkEnableOption "Enable system apps";
  };

  config = lib.mkIf cfg.enable {
    homeSpec.apps = {
      browsers.enable = true;
      cloud.enable = true;
      foot.enable = true;
      media.enable = true;
      nvim.enable = true;
      office.enable = true;
      pcmanfm.enable = true;
      printing.enable = true;
      protonvpn.enable = true;
      transmission.enable = true;
    };
  };
}
