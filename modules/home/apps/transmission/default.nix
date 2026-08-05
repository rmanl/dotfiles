{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.apps.transmission;
in
{
  options.homeSpec.apps.transmission = {
    enable = lib.mkEnableOption "Enable transmission torrent module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = [ pkgs.transmission_4-gtk ];
  };
}
