{
  flake.nixosModules.mangoBinds =
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
      mod = "SUPER";
      modshift = "${mod}+SHIFT";
    in
    {
      hjem.users.${userName}.files.".config/mango/binds.conf".text = ''
        # general
        bind=SUPER,r,reload_config # reload mango config
        bind=${mod},Return,spawn,${terminal} # open terminal
        bind=${mod},d,spawn,${launcher} # app launcher
        bind=${mod},Escape,spawn,powermenu # power menu
        bind=${modshift},slash,spawn_shell,codex # show codex overview

        # apps
        bind=${mod},F12,spawn_shell,prtscr # screenshot menu
        bind=${mod},v,spawn_shell,clipmenu # clipboard history picker
        bind=${modshift},c,spawn_shell,colorpick # color picker
        bind=${mod},w,spawn,${browser} # open browser
        bind=${mod},n,spawn,${fileManager} # file manager
        bind=${mod}+ALT,l,spawn,${locker} # lock screen

        # window
        bind=${mod},q,killclient # close focused window
        bind=${mod},f,togglefloating, # toggle floating
        bind=${modshift},f,togglefullscreen, # toggle fullscreen
        bind=${mod},j,focusstack,next # focus next
        bind=${mod},k,focusstack,prev # focus previous
        bind=${mod},h,focusdir,left # focus left
        bind=${mod},l,focusdir,right # focus right
        bind=${modshift},k,exchange_client,up # swap up
        bind=${modshift},j,exchange_client,down # swap down
        bind=${modshift},h,exchange_client,left # swap left
        bind=${modshift},l,exchange_client,right # swap right
        mousebind=${mod},btn_left,moveresize,curmove # move window (mouse drag)
        mousebind=${mod},btn_right,moveresize,curresize # resize window (mouse drag)
        gesturebind=none,left,3,focusdir,left # focus left (3-finger swipe)
        gesturebind=none,right,3,focusdir,right # focus right (3-finger swipe)
        gesturebind=none,up,3,focusdir,up # focus up (3-finger swipe)
        gesturebind=none,down,3,focusdir,down # focus down (3-finger swipe)

        # workspace
        bind=SUPER,1,view,1,0 # switch to workspace 1
        bind=SUPER,2,view,2,0 # switch to workspace 2
        bind=SUPER,3,view,3,0 # switch to workspace 3
        bind=SUPER,4,view,4,0 # switch to workspace 4
        bind=SUPER,5,view,5,0 # switch to workspace 5
        bind=SUPER,6,view,6,0 # switch to workspace 6
        bind=SUPER,7,view,7,0 # switch to workspace 7
        bind=SUPER,8,view,8,0 # switch to workspace 8
        bind=SUPER,9,view,9,0 # switch to workspace 9
        bind=${modshift},1,tagsilent,1 # move window to workspace 1 (stay focused)
        bind=${modshift},2,tagsilent,2 # move window to workspace 2 (stay focused)
        bind=${modshift},3,tagsilent,3 # move window to workspace 3 (stay focused)
        bind=${modshift},4,tagsilent,4 # move window to workspace 4 (stay focused)
        bind=${modshift},5,tagsilent,5 # move window to workspace 5 (stay focused)
        bind=${modshift},6,tagsilent,6 # move window to workspace 6 (stay focused)
        bind=${modshift},7,tagsilent,7 # move window to workspace 7 (stay focused)
        bind=${modshift},8,tagsilent,8 # move window to workspace 8 (stay focused)
        bind=${modshift},9,tagsilent,9 # move window to workspace 9 (stay focused)
        bind=SHIFT+ALT,1,tag,1,0 # move window to workspace 1 (and follow)
        bind=SHIFT+ALT,2,tag,2,0 # move window to workspace 2 (and follow)
        bind=SHIFT+ALT,3,tag,3,0 # move window to workspace 3 (and follow)
        bind=SHIFT+ALT,4,tag,4,0 # move window to workspace 4 (and follow)
        bind=SHIFT+ALT,5,tag,5,0 # move window to workspace 5 (and follow)
        bind=SHIFT+ALT,6,tag,6,0 # move window to workspace 6 (and follow)
        bind=SHIFT+ALT,7,tag,7,0 # move window to workspace 7 (and follow)
        bind=SHIFT+ALT,8,tag,8,0 # move window to workspace 8 (and follow)
        bind=SHIFT+ALT,9,tag,9,0 # move window to workspace 9 (and follow)
        axisbind=${mod},up,viewtoleft_have_client # previous workspace (with window)
        axisbind=${mod},down,viewtoright_have_client # next workspace (with window)
        gesturebind=none,left,4,viewtoleft_have_client # switch workspace left (4-finger swipe)
        gesturebind=none,right,4,viewtoright_have_client # switch workspace right (4-finger swipe)

        # media
        bind=none,XF86MonBrightnessUp,spawn,nc -U /tmp/barbie-bl.sock; brillo -q -u 300000 -A 5 # increase brightness
        bind=none,XF86MonBrightnessDown,spawn,nc -U /tmp/barbie-bl.sock; brillo -q -u 300000 -U 5 # decrease brightness
        bind=none,XF86AudioRaiseVolume,spawn,wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 5%+ # increase volume
        bind=none,XF86AudioLowerVolume,spawn,wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 5%- # decrease volume
        bind=none,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle # toggle mute
        bind=none,XF86AudioMicMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle # toggle mic mute
        bind=none,XF86AudioPlay,spawn,playerctl play-pause # play/pause media
        bind=none,XF86AudioPrev,spawn,playerctl previous # previous track
        bind=none,XF86AudioNext,spawn,playerctl next # next track
      '';
    };
}
