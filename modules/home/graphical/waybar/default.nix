{
  flake.nixosModules.waybar =
    {
      host,
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (host)
        isGaming
        isLaptop
        userName
        volumeMixer
        ;
      inherit (config) theme;
      c = config.colors;
      h = c.withHashtag;
      runOnce = program: "pgrep ${program} || ${program}";
    in
    {
      imports = [ ./_thermo.nix ];
      hjem.users.${userName} = {
        packages = [ pkgs.waybar ];
        files = {
          ".config/waybar/config" = {
            generator = lib.generators.toJSON { };
            value = {
              layer = "top";
              position = "top";
              mod = "dock";
              height = 33;
              exclusive = true;
              passthrough = false;
              gtk-layer-shell = true;

              modules-left = [
                "ext/workspaces"
                "custom/media_status"
              ]
              ++ lib.optionals isLaptop [
                "backlight"
                "battery"
              ];
              modules-center = [ "clock" ];
              modules-right = [
                "tray"
              ]
              ++ lib.optionals isGaming [ "custom/hwinfo" ]
              ++ [
                "wireplumber"
                "custom/megacmd"
                "idle_inhibitor"
              ];

              "ext/workspaces" = {
                active-only = false;
                all-outputs = false;
                format = "{icon}";
                format-icons = {
                  "1" = "󰬺";
                  "10" = "󰿩";
                  "2" = "󰬻";
                  "3" = "󰬼";
                  "4" = "󰬽";
                  "5" = "󰬾";
                  "6" = "󰬿";
                  "7" = "󰭀";
                  "8" = "󰭁";
                  "9" = "󰭂";
                };
                on-click = "activate";
                persistent-workspaces."*" = 5;
              };

              backlight = {
                format = "<span font='10'>{icon}</span>";
                format-icons = [
                  ""
                  ""
                  ""
                  ""
                  ""
                  ""
                  ""
                  ""
                  ""
                ];
                on-click = "brillo -S 80";
                tooltip-format = "{percent}%";
              };

              battery = {
                format = "<span font='10'>{icon}</span><span font='8'> {capacity}%</span>";
                format-alt = "{icon} {capacity}%";
                format-charging = "<span font='10'>󰂄</span>";
                format-icons = [
                  "󰁺"
                  "󰁻"
                  "󰁼"
                  "󰁽"
                  "󰁾"
                  "󰁿"
                  "󰂀"
                  "󰂁"
                  "󰂂"
                  "󰁹"
                ];
                format-plugged = "<span font='10'>󰚥</span>";
                states = {
                  critical = 15;
                  good = 99;
                  warning = 30;
                };
                tooltip-format = "{timeTo} {capacity}%";
              };

              "custom/media_status" = {
                exec = "media_status --scroll &";
                format = "<span font='12'>󰦚</span><span font='8'> {}</span>";
                on-click = "media_status --play-pause";
                tooltip = false;
              };

              clock = {
                format = "<span font='10'>{:%a %d | %H:%M}</span>";
                max-length = 20;
                min-length = 8;
                tooltip = false;
              };

              tray = {
                icon-size = 12;
                spacing = 6;
              };

              "custom/hwinfo" = {
                exec = "wb_thermo";
                interval = 30;
                return-type = "json";
              };

              "custom/megacmd" = {
                exec = "megacmd &";
                format = "{icon}";
                format-icons = {
                  active = "<span font='10'>󰘿</span>";
                  inactive = "<span font='12' color='${h.base03}'>󰏊</span>";
                };
                interval = 1;
                on-click = "megacmd --toggle";
                return-type = "json";
                tooltip = false;
              };

              wireplumber = {
                format = "<span font='12'>{icon}</span><span font='8'> {volume}%</span>";
                format-icons = [
                  "󰕿"
                  "󰖀"
                  "󰕾"
                ];
                format-muted = "<span font='12'>󰸈</span>";
                max-volume = 100;
                on-click = "${runOnce volumeMixer}";
                on-click-middle = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
                on-click-right = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%";
                on-scroll-down = "wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 5%-";
                on-scroll-up = "wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 5%+";
                scroll-step = 5;
                tooltip = false;
              };

              idle_inhibitor = {
                format = "{icon}";
                format-icons = {
                  activated = "<span font='9'></span>";
                  deactivated = "<span font='9' color='${h.base03}'></span>";
                };
                tooltip = false;
              };
            };
          };
          ".config/waybar/style.css".text = ''
            * {
              font-family: Material Design Icons, monospace;
            }

            window#waybar {
              background-color: rgba(${theme.toRGB c.base00},0.1);
              color: ${h.base06};
              font-size: 16px;
              transition-property: background-color;
              transition-duration: 0.5s;
            }

            window#waybar.hidden {
              opacity: 0.2;
            }

            #workspaces {
              font-size: 18px;
              background-color: rgba(${theme.toRGB c.base01},0.7);
              border-radius: 3px;
              margin: 5px 4px 5px 0;
              padding: 0 8px;
            }

            #workspaces button {
              background-color: transparent;
              box-shadow: inset 0 -3px transparent;
              transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.68);
              margin: 0;
              padding: 0;
            }

            #workspaces button.empty {
              background-color: rgba(${theme.toRGB c.base01},0.7);
            }

            #workspaces button.active {
              color: ${h.base0C};
            }

            #workspaces button:hover {
              color: ${h.base0C};
              box-shadow: inherit;
              text-shadow: inherit;
            }

            #workspaces button.urgent {
              color: ${h.base08};
            }

            tooltip {
              background: ${h.base00};
              opacity: 0.85;
              border-radius: 7px;
              margin: 10px;
              padding: 5px;
            }

            tooltip label {
              font-family: sans-serif;
              font-size: 12px;
            }

            #backlight,
            #battery,
            #clock,
            #custom-media_status,
            #tray,
            #wireplumber,
            #custom-megacmd,
            #custom-hwinfo,
            #idle_inhibitor {
              margin: 5px 0;
              padding-right: 3px;
            }

            #custom-media_status {
              background-color: rgba(${theme.toRGB c.base01},0.7);
              border-radius: 3px;
              margin-right: 4px;
              padding: 0 8px;
            }

            #backlight {
              background-color: rgba(${theme.toRGB c.base01},0.7);
              border-radius: 3px 0 0 3px;
              padding-left: 8px;
            }

            #battery {
              background-color: rgba(${theme.toRGB c.base01},0.7);
              border-radius: 0 3px 3px 0;
              padding-left: 3px;
              padding-right: 8px;
            }

            #battery.warning {
              color: ${h.base09};
            }

            #battery.critical:not(.charging) {
              color: ${h.base08};
            }

            #clock {
              background-color: rgba(${theme.toRGB c.base01},0.7);
              border-radius: 3px;
              margin-right: 4px;
              padding: 0 8px;
            }

            #tray {
              background-color: rgba(${theme.toRGB c.base01},0.7);
              border-radius: 3px;
              margin-right: 4px;
              padding: 0 8px;
            }

            #custom-hwinfo {
              font-size: 10px;
              background-color: rgba(${theme.toRGB c.base01},0.7);
              border-radius: 3px;
              margin-right: 4px;
              padding: 0 8px;
            }

            #wireplumber {
              background-color: rgba(${theme.toRGB c.base01},0.7);
              border-radius: 3px 0 0 3px;
              padding-left: 8px;
            }

            #custom-megacmd {
              background-color: rgba(${theme.toRGB c.base01},0.7);
              padding: 0 3px;
            }

            #idle_inhibitor {
              background-color: rgba(${theme.toRGB c.base01},0.7);
              border-radius: 0 3px 3px 0;
              margin-right: 4px;
              padding-left: 3px;
              padding-right: 8px;
            }
          '';
        };
      };
    };
}
