{
  flake.nixosModules.mangoConfig =
    { host, config, ... }:
    let
      inherit (config.theme) cursorName cursorSize;
      c = config.colors;
    in
    {
      hjem.users.${host.userName}.files.".config/mango/config.conf".text = ''
        # autostart
        exec_once=~/.config/mango/autostart.sh

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
        shadows_color= 0x${c.base00}ff

        border_radius=0
        no_radius_when_single=0
        focused_opacity=1.0
        unfocused_opacity=1.0

        # animations
        animations=0

        # master-stack layout settings
        new_is_master=0
        smart_gaps=0
        default_master_factor=0.55
        default_master_count=1

        # overview settings
        enable_hotarea=0

        # misc
        enable_border_resize=0
        xwayland_persistence=1
        sync_obj_enable=0
        no_border_when_single=0
        axis_bind_apply_timeout=100
        focus_on_activate=1
        sloppy_focus=1
        warp_cursor=1
        focus_cross_monitor=0
        focus_cross_tag=0
        circle_layout=tile,scroller
        enable_floating_snap=1
        snap_distance=50
        cursor_size=${toString cursorSize}
        cursor_theme=${cursorName}
        cursor_hide_timeout=0
        drag_tile_to_tile=1
        single_scratchpad=1

        # keyboard
        repeat_rate=25
        repeat_delay=600
        numlock_on=0
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
        trackpad_disable_while_typing=1
        trackpad_left_handed=0
        trackpad_middle_button_emulation=0
        swipe_min_threshold=1
        trackpad_accel_profile=2
        trackpad_accel_speed=0.0
        # scroll_button=274
        # scroll_method=1

        # appearance
        gap_inner_horizontal=0
        gap_inner_vertical=0
        gap_outer_horizontal=0
        gap_outer_vertical=0
        border_px=1
        root_color=0x${c.base02}ff
        border_color=0x${c.base01}ff
        focus_color=0x${c.base0C}ff
        maximized_screen_color=0x${c.base0C}ff
        urgent_color=0x${c.base08}ff

        # sub config load
        source=~/.config/mango/binds.conf
        source=~/.config/mango/env.conf
        source=~/.config/mango/rules.conf
        source=~/.config/mango/scratchpads.conf
      '';
    };
}
