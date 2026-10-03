{
  flake.nixosModules.mangoAutostart =
    { host, config, ... }:
    {
      hjem.users.${host.userName}.files.".config/mango/autostart.sh" = {
        executable = true;
        text = ''
          set +e

          # ensure xdg-desktop-portal running without last dirty state
          systemctl --user restart xdg-desktop-portal >/dev/null 2>&1 &

          waybar >/dev/null 2>&1 &

          # brightness at boot
          brillo -S 80 >/dev/null 2>&1 &

          # tray icons
          protonvpn-app >/dev/null 2>&1 &
          blueman-applet >/dev/null 2>&1 &
          nm-applet >/dev/null 2>&1 &
          udiskie --appindicator -s -n -a >/dev/null 2>&1 &

          # polkit auth agent
          polkit-agent >/dev/null 2>&1 &

          # clipboard history
          wl-paste --watch cliphist store &

          # disable megacmd at boot
          megacmd --boot

          # wallpaper
          awww-daemon >/dev/null 2>&1 &
          sleep 1
          awww img ${config.theme.wallpaper} >/dev/null 2>&1 &

          # idle manager
          systemctl --user start hypridle
        '';
      };
    };
}
