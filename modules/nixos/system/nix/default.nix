{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.system.nix;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.sysSpec.system.nix = {
    enable = lib.mkEnableOption "Enable nix modules";
  };

  config = lib.mkIf cfg.enable {
    sysSpec.system.nix = {
      extra.enable = true;
      lix.enable = true;
      substituters.enable = true;
    };
  };
}
