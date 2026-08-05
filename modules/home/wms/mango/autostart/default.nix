{
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.wms.mango.autostart;
  inherit (config.hostSpec) userName;
in
{
  options.homeSpec.wms.mango.autostart = {
    enable = lib.mkEnableOption "Enable mango autostart module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${userName}.files.".config/mango/autostart.sh" = {
      executable = true;
      text = ''
        set +e

        waybar >/dev/null 2>&1 &

        # brightness at boot
        brillo -S 80 >/dev/null 2>&1 &

        # tray icons
        protonvpn-app >/dev/null 2>&1 &
        blueman-applet >/dev/null 2>&1 &
        nm-applet >/dev/null 2>&1 &
        udiskie --appindicator -s -n -a >/dev/null 2>&1 &

        # disable megacmd at boot
        cloud --boot

        # wallpaper
        awww-daemon >/dev/null 2>&1 &
        awww img ${config.theme.wallpaper} >/dev/null 2>&1 &

        # idle manager
        systemctl --user start hypridle
      '';
    };
  };
}
