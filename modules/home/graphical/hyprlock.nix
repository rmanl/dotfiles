{
  flake.nixosModules.hyprlock =
    {
      host,
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.theme) toRGB wallpaper;
      c = config.colors;
    in
    {
      hjem.users.${host.userName} = {
        packages = [ pkgs.hyprlock ];
        files.".config/hypr/hyprlock.conf".text = ''
          background {
            blur_passes=3
            blur_size=8
            color=rgb${toRGB c.base00}
            path=${wallpaper}
          }

          general {
            disable_loading_bar=true
            grace=5
            hide_cursor=false
            immediate_render=true
            no_fade_in=true
          }

          input-field {
            monitor=
            size=300, 50
            check_color=rgba(${toRGB c.base0A}, 0.5)
            dots_center=true
            dots_fade_time=100
            dots_spacing=0.200000
            fade_on_empty=false
            fail_color=rgba(${toRGB c.base08}, 0.5)
            font_color=rgb(${c.base05})
            inner_color=rgba(${toRGB c.base00}, 0.1)
            outer_color=rgba(${toRGB c.base0D}, 0.5)
            outline_thickness=1
            placeholder_text=Password...
            shadow_color=rgba(${toRGB c.base05}, 0.1)
            shadow_passes=2
            shadow_size=7
          }

          label {
            monitor=
            color=rgba(${c.base0D})
            font_size=95
            halign=center
            position=0, 300
            shadow_boost=0.300000
            shadow_color=rgba(${toRGB c.base00}, 0.1)
            shadow_passes=2
            shadow_size=20
            text=$TIME
            valign=center
          }

          label {
            monitor=
            color=rgb(${toRGB c.base0D})
            font_size=22
            halign=center
            position=0, 200
            shadow_boost=0.300000
            shadow_color=rgba(${toRGB c.base00}, 0.1)
            shadow_passes=2
            shadow_size=20
            text=cmd[update:600000] date +'%A %B %d'
            valign=center
          }
          animation=inputFieldDots, 1, 2, linear
          animation=fadeIn, 0
        '';
      };
    };
}
