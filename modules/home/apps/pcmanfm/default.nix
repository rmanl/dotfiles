{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.apps.pcmanfm;
in
{
  options.homeSpec.apps.pcmanfm = {
    enable = lib.mkEnableOption "Enable pcmanfm file manager module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = [ pkgs.pcmanfm ];
  };
}
