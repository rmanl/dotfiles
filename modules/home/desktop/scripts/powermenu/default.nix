{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.desktop.scripts.powermenu;
  powermenu = pkgs.writeShellScriptBin "powermenu" ''
    SELECTION="$(printf "󰌾 Lock\n󰍃 Logout\n󰜉 Reboot\n󰤆 Shutdown" | fuzzel -d -l 4 -w 15 -p "Power ")"

    case $SELECTION in
    *"Lock")
      hyprlock
      ;;
    *"Logout")
      pkill -KILL -u "$USER"
      ;;
    *"Reboot")
      systemctl reboot
      ;;
    *"Shutdown")
      systemctl poweroff
      ;;
    esac
  '';
in
{
  options.homeSpec.desktop.scripts.powermenu = {
    enable = lib.mkEnableOption "Enable powermenu script";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = [ powermenu ];
  };
}
