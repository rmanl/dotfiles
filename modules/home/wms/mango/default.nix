{
  flake,
  config,
  lib,
  pkgs,
  perSystem,
  ...
}:
let
  cfg = config.homeSpec.wms.mango;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.homeSpec.wms.mango = {
    enable = lib.mkEnableOption "Enable mango module";
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

    homeSpec = {
      wms.mango = {
        autostart.enable = true;
        binds.enable = true;
        config.enable = true;
        env.enable = true;
        ipc.enable = true;
        rules.enable = true;
        scratchpads.enable = true;
      };
    };
  };
}
