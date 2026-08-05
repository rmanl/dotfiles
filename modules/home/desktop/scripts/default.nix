{
  flake,
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.desktop.scripts;
in
{
  imports = flake.lib.importModules { dir = ./.; };

  options.homeSpec.desktop.scripts = {
    enable = lib.mkEnableOption "Enable scripts modules";
  };

  config = lib.mkIf cfg.enable {
    homeSpec.desktop.scripts = {
      cloud.enable = true;
      media_status.enable = true;
      powermenu.enable = true;
      prtscr.enable = true;
      scroll_media_status.enable = true;
    };
  };
}
