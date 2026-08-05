{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.shell.zsh;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.homeSpec.shell.zsh = {
    enable = lib.mkEnableOption "Enable zsh modules";
  };

  config = lib.mkIf cfg.enable {
    homeSpec.shell.zsh = {
      config.enable = true;
      dev-template.enable = true;
    };
  };
}
