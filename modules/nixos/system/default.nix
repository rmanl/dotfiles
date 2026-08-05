{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.system;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.sysSpec.system = {
    enable = lib.mkEnableOption "Enable system modules";
  };

  config = lib.mkIf cfg.enable {
    sysSpec.system = {
      fonts.enable = true;
      lanzaboote.enable = true;
      network.enable = true;
      nix.enable = true;
      settings.enable = true;
      ssh.enable = true;
      theming.enable = true;
      zramswap.enable = true;
    };
  };
}
