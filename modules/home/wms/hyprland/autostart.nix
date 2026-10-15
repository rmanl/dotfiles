{
  flake.nixosModules.hyprlandAutostart =
    { host, config, ... }:
    let
      inherit (host) blueman vpn;
    in
    {
      hjem.users.${host.userName} = {
        files.".config/hypr/hyprpaper.conf".text = ''
          wallpaper {
            monitor =
            path = ${config.theme.wallpaper}
            fit_mode = cover
          }

          splash = false
        '';

        files.".config/hypr/hyprland.lua".text = ''
          hl.on("hyprland.start", function()
            hl.exec_cmd("systemctl --user restart xdg-desktop-portal")
            hl.exec_cmd("waybar")
            hl.exec_cmd("brillo -S 80")
            hl.exec_cmd("${vpn}")
            hl.exec_cmd("${blueman}")
            hl.exec_cmd("nm-applet")
            hl.exec_cmd("udiskie --appindicator -s -n -a")
            hl.exec_cmd("polkit-agent")
            hl.exec_cmd("wl-paste --watch cliphist store")
            hl.exec_cmd("megacmd --boot")
            hl.exec_cmd("hyprpaper")
            hl.exec_cmd("systemctl --user start hypridle")
          end)
        '';
      };
    };
}
