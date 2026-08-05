{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.desktop.xdg.portal;
in
{
  options.homeSpec.desktop.xdg.portal = {
    enable = lib.mkEnableOption "Enable sytem xdg portal module";
  };

  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config = {
        common.default = [ "gtk" ];
        hyprland.default = [
          "gtk"
          "hyprland"
        ];
      };

      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };
}
