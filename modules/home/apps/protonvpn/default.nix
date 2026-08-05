{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.apps.protonvpn;
in
{
  options.homeSpec.apps.protonvpn = {
    enable = lib.mkEnableOption "Enable protonvpn module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = [ pkgs.proton-vpn ];
  };
}
