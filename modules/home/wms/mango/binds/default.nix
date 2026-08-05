{
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.wms.mango.binds;
  mod = "SUPER";
  modshift = "${mod}+SHIFT";
in
{
  options.homeSpec.wms.mango.binds = {
    enable = lib.mkEnableOption "Enable mango keybinds module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.files.".config/mango/binds.conf".text = ''
      # reload config
      bind=SUPER,r,reload_config

      # menu and terminal
      bind=${mod},Return,spawn,foot
      bind=${mod},d,spawn,fuzzel
      bind=${mod},Escape,spawn,powermenu

      bind=${mod},q,killclient

      # custom app bind
      bind=${mod},F12,spawn_shell,prtscr
      # bind=${modshift},F12,spawn_shell,prtscr --area
      bind=${mod},w,spawn,${config.hostSpec.browser}
      bind=${mod},n,spawn,pcmanfm
      bind=${mod}+ALT,l,spawn,hyprlock

      bind=${mod},f,togglefloating,
      bind=${modshift},f,togglefullscreen,

      # switch window focus
      bind=${mod},j,focusstack,next
      bind=${mod},k,focusstack,prev
      bind=${mod},h,focusdir,left
      bind=${mod},l,focusdir,right

      # swap window
      bind=${modshift},k,exchange_client,up
      bind=${modshift},j,exchange_client,down
      bind=${modshift},h,exchange_client,left
      bind=${modshift},l,exchange_client,right

      # switch workspace
      bind=SUPER,1,view,1,0
      bind=SUPER,2,view,2,0
      bind=SUPER,3,view,3,0
      bind=SUPER,4,view,4,0
      bind=SUPER,5,view,5,0
      bind=SUPER,6,view,6,0
      bind=SUPER,7,view,7,0
      bind=SUPER,8,view,8,0
      bind=SUPER,9,view,9,0

      # move window to workspace
      bind=${modshift},1,tagsilent,1
      bind=${modshift},2,tagsilent,2
      bind=${modshift},3,tagsilent,3
      bind=${modshift},4,tagsilent,4
      bind=${modshift},5,tagsilent,5
      bind=${modshift},6,tagsilent,6
      bind=${modshift},7,tagsilent,7
      bind=${modshift},8,tagsilent,8
      bind=${modshift},9,tagsilent,9

      # move window to workspace & focus
      bind=SHIFT+ALT,1,tag,1,0
      bind=SHIFT+ALT,2,tag,2,0
      bind=SHIFT+ALT,3,tag,3,0
      bind=SHIFT+ALT,4,tag,4,0
      bind=SHIFT+ALT,5,tag,5,0
      bind=SHIFT+ALT,6,tag,6,0
      bind=SHIFT+ALT,7,tag,7,0
      bind=SHIFT+ALT,8,tag,8,0
      bind=SHIFT+ALT,9,tag,9,0

      # mouse
      mousebind=${mod},btn_left,moveresize,curmove
      mousebind=${mod},btn_right,moveresize,curresize
      axisbind=${mod},up,viewtoleft_have_client
      axisbind=${mod},down,viewtoright_have_client

      # gesturebind
      gesturebind=none,left,3,focusdir,left
      gesturebind=none,right,3,focusdir,right
      gesturebind=none,up,3,focusdir,up
      gesturebind=none,down,3,focusdir,down
      gesturebind=none,left,4,viewtoleft_have_client
      gesturebind=none,right,4,viewtoright_have_client
      gesturebind=none,up,4,toggleoverview
      gesturebind=none,down,4,toggleoverview
      bind=SUPER,0,toggleoverview

      # brightness controls
      bind=none,XF86MonBrightnessUp,spawn,nc -U /tmp/barbie-bl.sock; brillo -q -u 300000 -A 5
      bind=none,XF86MonBrightnessDown,spawn,nc -U /tmp/barbie-bl.sock; brillo -q -u 300000 -U 5

      # volume controls
      bind=none,XF86AudioRaiseVolume,spawn,wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 5%+
      bind=none,XF86AudioLowerVolume,spawn,wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 5%-
      bind=none,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bind=none,XF86AudioMicMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

      # media controls
      bind=none,XF86AudioPlay,spawn,playerctl play-pause
      bind=none,XF86AudioPrev,spawn,playerctl previous
      bind=none,XF86AudioNext,spawn,playerctl next
    '';
  };
}
