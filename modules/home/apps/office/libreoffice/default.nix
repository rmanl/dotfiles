{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.apps.office.libreoffice;
in
{
  options.homeSpec.apps.office.libreoffice = {
    enable = lib.mkEnableOption "Enable libreoffice module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = [ pkgs.libreoffice-still ];
  };
}
