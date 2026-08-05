{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.gaming.gamemode;
  inherit (config.hostSpec) userName;
in
{
  options.homeSpec.gaming.gamemode = {
    enable = lib.mkEnableOption "Enable gamemode module";
  };

  config = lib.mkIf cfg.enable {
    programs.gamemode = {
      enable = true;
      settings.general.renice = 20;
    };
    environment.systemPackages = [ pkgs.gnomeExtensions.gamemode-shell-extension ];
    users.users.${userName}.extraGroups = [ "gamemode" ];
  };
}
