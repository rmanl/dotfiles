{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.shell;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.homeSpec.shell = {
    enable = lib.mkEnableOption "Enable system shell modules";
  };

  config = lib.mkIf cfg.enable {
    homeSpec.shell = {
      bash.enable = true;
      bat.enable = true;
      btop.enable = true;
      claude.enable = true;
      direnv.enable = true;
      git.enable = true;
      pkgs.enable = true;
      starship.enable = true;
      zsh.enable = true;
    };
  };
}
