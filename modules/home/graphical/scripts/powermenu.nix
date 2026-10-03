{
  flake.nixosModules.scriptsPowermenu =
    { host, pkgs, ... }:
    let
      inherit (host) locker;
      powermenu = pkgs.writeShellScriptBin "powermenu" ''
        SELECTION="$(printf "󰌾 Lock\n󰍃 Logout\n󰜉 Reboot\n󰤆 Shutdown" | fuzzel -d -l 4 -w 15 -p "Power ")"

        case $SELECTION in
        *"Lock")
          ${locker}
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
      hjem.users.${host.userName}.packages = [ powermenu ];
    };
}
