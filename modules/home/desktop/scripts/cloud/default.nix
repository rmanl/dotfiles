{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.desktop.scripts.cloud;
  cloud = pkgs.writeShellScriptBin "cloud" ''
    STATUS=$(systemctl --user is-active mega-cmd | grep active | tr -d ' ' | cut -d ':' -f2)

    if [ "$STATUS" = "active" ]; then
    echo '{"alt":"active"}'
    else
    echo '{"alt":"inactive"}'
    fi

    cloud_toggle() {
    if systemctl --user is-active mega-cmd | grep "inactive"; then
    systemctl --user start mega-cmd >>/dev/null
    notify-send -u normal -t 3000 -a Cloud "Storage Connected" -i "skydrive"
    sleep 1
    else
    systemctl --user stop mega-cmd >>/dev/null
    notify-send -u normal -t 3000 -a Cloud "Storage Disconnected" -i "skydrive"
    fi
    }

    cloud_boot() {
    systemctl --user stop mega-cmd >>/dev/null
    }

    case "$1" in
    --toggle)
    cloud_toggle
    ;;
    --boot)
    cloud_boot
    ;;
    *) ;;
    esac
  '';
in
{
  options.homeSpec.desktop.scripts.cloud = {
    enable = lib.mkEnableOption "Enable cloud script";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = [ cloud ];
  };
}
