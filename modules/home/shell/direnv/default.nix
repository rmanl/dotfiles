{
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.shell.direnv;
in
{
  options.homeSpec.shell.direnv = {
    enable = lib.mkEnableOption "Enable direnv module";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
