{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.shell.bat;
in
{
  options.homeSpec.shell.bat = {
    enable = lib.mkEnableOption "Enable bat module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName} = {
      packages = with pkgs; [
        bat # cat
        bat-extras.batman # manpage
      ];
      files.".config/bat/config".text = ''
        --style=numbers,changes
      '';
      environment.sessionVariables = {
        BAT_STYLE = "numbers,changes";
      };
    };
  };
}
