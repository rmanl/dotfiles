{
  flake.nixosModules.hyprlandBinds =
    { host, ... }:
    let
      inherit (host)
        browser
        fileManager
        launcher
        locker
        terminal
        userName
        ;
    in
    {
      hjem.users.${userName}.files.".config/hypr/hyprland.lua".text = ''
        -- general
        hl.bind("SUPER+RETURN", hl.dsp.exec_cmd("${terminal}"), { description = "open terminal" })
        hl.bind("SUPER+D", hl.dsp.exec_cmd("${launcher}"), { description = "app launcher" })
        hl.bind("SUPER+ESCAPE", hl.dsp.exec_cmd("powermenu"), { description = "power menu" })
        hl.bind("SUPER+SHIFT+SLASH", hl.dsp.exec_cmd("codex"), { description = "show codex overview" })

        -- apps
        hl.bind("SUPER+F12", hl.dsp.exec_cmd("prtscr"), { description = "screenshot menu" })
        hl.bind("SUPER+V", hl.dsp.exec_cmd("clipmenu"), { description = "clipboard history picker" })
        hl.bind("SUPER+SHIFT+C", hl.dsp.exec_cmd("colorpick"), { description = "color picker" })
        hl.bind("SUPER+W", hl.dsp.exec_cmd("${browser}"), { description = "open browser" })
        hl.bind("SUPER+N", hl.dsp.exec_cmd("${fileManager}"), { description = "file manager" })
        hl.bind("SUPER+ALT+L", hl.dsp.exec_cmd("${locker}"), { description = "lock screen" })

        -- window
        hl.bind("SUPER+Q", hl.dsp.window.kill(), { description = "close focused window" })
        hl.bind("SUPER+F", hl.dsp.window.float({ action = "toggle" }), { description = "toggle floating" })
        hl.bind("SUPER+SHIFT+F", hl.dsp.window.fullscreen({ action = "toggle" }), { description = "toggle fullscreen" })
        hl.bind("SUPER+J", hl.dsp.window.cycle_next({ next = true }), { description = "focus next" })
        hl.bind("SUPER+K", hl.dsp.window.cycle_next({ next = false }), { description = "focus previous" })
        hl.bind("SUPER+H", hl.dsp.focus({ direction = "left" }), { description = "focus left" })
        hl.bind("SUPER+L", hl.dsp.focus({ direction = "right" }), { description = "focus right" })
        hl.bind("SUPER+SHIFT+K", hl.dsp.window.swap({ direction = "up" }), { description = "swap up" })
        hl.bind("SUPER+SHIFT+J", hl.dsp.window.swap({ direction = "down" }), { description = "swap down" })
        hl.bind("SUPER+SHIFT+H", hl.dsp.window.swap({ direction = "left" }), { description = "swap left" })
        hl.bind("SUPER+SHIFT+L", hl.dsp.window.swap({ direction = "right" }), { description = "swap right" })
        hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "move window (mouse drag)" })
        hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "resize window (mouse drag)" })
        hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "left" })) end })
        hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "right" })) end })
        hl.gesture({ fingers = 3, direction = "up", action = function() hl.dispatch(hl.dsp.focus({ direction = "up" })) end })
        hl.gesture({ fingers = 3, direction = "down", action = function() hl.dispatch(hl.dsp.focus({ direction = "down" })) end })

        -- workspace
        for i = 1, 9 do
          hl.bind("SUPER+" .. i, hl.dsp.focus({ workspace = tostring(i) }), { description = "switch to workspace " .. i })
          hl.bind("SUPER+SHIFT+" .. i, hl.dsp.window.move({ workspace = tostring(i), follow = false }), { description = "move window to workspace " .. i .. " (stay focused)" })
          hl.bind("SHIFT+ALT+" .. i, hl.dsp.window.move({ workspace = tostring(i), follow = true }), { description = "move window to workspace " .. i .. " (and follow)" })
        end
        hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })

        -- media
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("nc -U /tmp/barbie-bl.sock; brillo -q -u 300000 -A 5"), { repeating = true, description = "increase brightness" })
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("nc -U /tmp/barbie-bl.sock; brillo -q -u 300000 -U 5"), { repeating = true, description = "decrease brightness" })
        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true, description = "increase volume" })
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true, description = "decrease volume" })
        hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, description = "toggle mute" })
        hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, description = "toggle mic mute" })
        hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "play/pause media" })
        hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, description = "previous track" })
        hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "next track" })
      '';
    };
}
