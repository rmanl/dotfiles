{
  config,
  lib,
  pkgs,
  perSystem,
  ...
}:
let
  cfg = config.homeSpec.wms.mango.core;
in
{
  options.homeSpec.wms.mango.core = {
    enable = lib.mkEnableOption "Enable mango core module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages =
      with pkgs;
      [
        grim
        hyprlock
        slurp
        wcalc
        xdg-desktop-portal
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ]
      ++ [
        perSystem.nixpkgs-unstable.mango
      ];
  };
}
