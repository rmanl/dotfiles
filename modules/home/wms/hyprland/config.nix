{
  flake.nixosModules.hyprlandConfig =
    { host, config, ... }:
    let
      c = config.colors;
    in
    {
      hjem.users.${host.userName}.files.".config/hypr/hyprland.lua".text = ''
        hl.config({
          general = {
            gaps_in = 0,
            gaps_out = 0,
            border_size = 1,
            layout = "master",
            col = {
              active_border = 0xff${c.base0C},
              inactive_border = 0xff${c.base01},
              nogroup_border = 0xff${c.base01},
              nogroup_border_active = 0xff${c.base0C},
            },
          },
          master = {
            new_status = "slave",
          },
          decoration = {
            rounding = 0,
            blur = {
              enabled = true,
              size = 2,
              passes = 2,
              noise = 0.02,
              contrast = 0.9,
              brightness = 0.9,
            },
            shadow = {
              enabled = true,
              range = 12,
              render_power = 3,
            },
          },
          animations = {
            enabled = false,
          },
          input = {
            repeat_rate = 25,
            repeat_delay = 600,
            numlock_by_default = false,
            kb_options = "caps:escape_shifted_capslock",
            touchpad = {
              natural_scroll = false,
              tap_to_click = true,
              tap_and_drag = true,
              drag_lock = 1,
              disable_while_typing = true,
            },
          },
        })
      '';
    };
}
