{
  flake,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.desktop;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.homeSpec.desktop = {
    enable = lib.mkEnableOption "Enable system desktop modules";
  };

  config = lib.mkIf cfg.enable {
    homeSpec.desktop = {
      awww.enable = true;
      felix.enable = true;
      fuzzel.enable = true;
      gtk.enable = true;
      hypridle.enable = true;
      hyprlock.enable = true;
      mako.enable = true;
      scripts.enable = true;
      waybar.enable = true;
      xdg.enable = true;
    };

    environment.systemPackages = with pkgs; [
      wl-clipboard
      wlr-randr
    ];
  };
}
