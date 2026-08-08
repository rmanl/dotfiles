{
  flake.nixosModules.scriptsMegacmd =
    { host, pkgs, ... }:
    let
      megacmd = pkgs.writeShellScriptBin "megacmd" ''
        get_ids() {
          mega-sync 2>/dev/null | tail -n +2 | awk '{print $1}'
        }

        is_running() {
          mega-sync 2>/dev/null | tail -n +2 | awk '{print $4}' | grep -q Running
        }

        if is_running; then
        echo '{"alt":"active"}'
        else
        echo '{"alt":"inactive"}'
        fi

        megacmd_toggle() {
        if is_running; then
        for id in $(get_ids); do mega-sync -p "$id" >>/dev/null; done
        notify-send -u normal -t 3000 -a Cloud "Sync Paused" -i "skydrive"
        else
        for id in $(get_ids); do mega-sync -e "$id" >>/dev/null; done
        notify-send -u normal -t 3000 -a Cloud "Sync Resumed" -i "skydrive"
        sleep 1
        fi
        }

        megacmd_boot() {
        for id in $(get_ids); do mega-sync -p "$id" >>/dev/null; done
        }

        case "$1" in
        --toggle)
        megacmd_toggle
        ;;
        --boot)
        megacmd_boot
        ;;
        *) ;;
        esac
      '';
    in
    {
      hjem.users.${host.userName}.packages = [ megacmd ];
    };
}
