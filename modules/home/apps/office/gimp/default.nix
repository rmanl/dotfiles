{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.apps.office.gimp;
in
{
  options.homeSpec.apps.office.gimp = {
    enable = lib.mkEnableOption "Enable gimp module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = [ pkgs.gimp3 ];
  };
}
