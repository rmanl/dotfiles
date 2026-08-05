{
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.wms.mango.config;
in
{
  options.homeSpec.wms.mango.config = {
    enable = lib.mkEnableOption "Enable mango config module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.files.".config/mango/config.conf".text =
      with config.colors; ''
        # autostart
        exec-once=~/.config/mango/autostart.sh

        # effect
        blur=1
        blur_layer=1
        blur_optimized=1
        blur_params_num_passes=2
        blur_params_radius=2
        blur_params_noise=0.02
        blur_params_brightness=0.9
        blur_params_contrast=0.9
        blur_params_saturation=1.2

        shadows=1
        layer_shadows=1
        shadow_only_floating=1
        shadows_size=12
        shadows_blur=15
        shadows_position_x=0
        shadows_position_y=0
        shadowscolor= 0x${base00}ff

        border_radius=0
        no_radius_when_single=0
        focused_opacity=1.0
        unfocused_opacity=1.0

        # animations
        animations=0

        # master-stack layout settings
        new_is_master=0
        smartgaps=0
        default_mfact=0.55
        default_nmaster=1

        # overview settings
        enable_hotarea=0
        ov_tab_mode=0

        # misc
        xwayland_persistence=1
        syncobj_enable=0
        no_border_when_single=0
        axis_bind_apply_timeout=100
        focus_on_activate=1
        sloppyfocus=1
        warpcursor=1
        focus_cross_monitor=0
        focus_cross_tag=0
        circle_layout=tile,scroller
        enable_floating_snap=1
        snap_distance=50
        cursor_size=24
        cursor_theme=capitaine-cursors
        cursor_hide_timeout=0
        drag_tile_to_tile=1
        single_scratchpad=1

        # keyboard
        repeat_rate=25
        repeat_delay=600
        numlockon=0
        xkb_rules_layout=us
        xkb_rules_options=caps:escape_shifted_capslock

        # mouse
        mouse_accel_profile=0

        # trackpad
        disable_trackpad=0
        tap_to_click=1
        tap_and_drag=1
        drag_lock=1
        mouse_natural_scrolling=0
        trackpad_natural_scrolling=0
        disable_while_typing=1
        left_handed=0
        middle_button_emulation=0
        swipe_min_threshold=1
        trackpad_accel_profile=2
        trackpad_accel_speed=0.0
        # scroll_button=274
        # scroll_method=1

        # appearance
        gappih=0
        gappiv=0
        gappoh=0
        gappov=0
        borderpx=1
        rootcolor=0x${base02}ff
        bordercolor=0x${base01}ff
        focuscolor=0x${base0C}ff
        maximizescreencolor=0x${base0C}ff
        urgentcolor=0x${base08}ff

        # sub config load
        source=~/.config/mango/binds.conf
        source=~/.config/mango/env.conf
        source=~/.config/mango/rules.conf
        source=~/.config/mango/scratchpads.conf
      '';
  };
}
