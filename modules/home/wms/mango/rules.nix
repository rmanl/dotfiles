{
  flake.nixosModules.mangoRules =
    { host, ... }:
    let
      inherit (host) mangoMonitor userName;
    in
    {
      hjem.users.${userName}.files.".config/mango/rules.conf".text = ''
        # monitor
        monitorrule=${mangoMonitor}
        # layouts in mango are per tag. so we'll set all tags to tile by default.
        tagrule=id:1,layout_name:tile
        tagrule=id:2,layout_name:tile
        tagrule=id:3,layout_name:tile
        tagrule=id:4,layout_name:tile
        tagrule=id:5,layout_name:tile
        tagrule=id:6,layout_name:tile
        tagrule=id:7,layout_name:tile
        tagrule=id:8,layout_name:tile
        tagrule=id:9,layout_name:tile

        # screenshot fix
        layerrule=noblur:1,layer_name:selection

        # dialogs
        windowrule=isfloating:1,title:^(Open File)(.*)$
        windowrule=isfloating:1,title:^(Select a File)(.*)$
        windowrule=isfloating:1,title:^(Choose wallpaper)(.*)$
        windowrule=isfloating:1,title:^(Open Folder)(.*)$
        windowrule=isfloating:1,title:^(Save As)(.*)$
        windowrule=isfloating:1,title:^(Library)(.*)$
        windowrule=isfloating:1,title:^(Accounts)(.*)$

        # nmtui network-manager
        windowrule=isfloating:1,width:800,height:600,appid:foot,title:^(nmtui)$

        # bluetooth
        windowrule=isfloating:1,appid:.blueman-manager-wrapped

        # seahorse(gnome-keyring ui)
        windowrule=isfloating:1,width:800,height:600,appid:org.gnome.seahorse.Application

        # volume control
        windowrule=isfloating:1,width:800,height:600,appid:com.saivert.pwvucontrol

        # pcmanfm
        windowrule=isfloating:1,width:800,height:600,appid:pcmanfm

        # imv image viewer
        windowrule=isfullscreen:1,appid:imv

        # proton vpn
        windowrule=width:450,height:800,appid:.proton-app-wrapped

        # spotify
        windowrule=force_tiled_state:1,istagsilent:1,tags:5,title:^([Ss]potify)(.*)$

        # steam
        windowrule=force_tiled_state:1,tags:4,appid:^([Ss]team)$
        windowrule=width:340,height:800,tags:4,title:^(Friends List)$,appid:^([Ss]team)$

        # bottles
        windowrule=force_tiled_state:1,tags:4,title:^([Bb]ottles)(.*)$

        # heroic
        windowrule=force_tiled_state:1,tags:4,title:^([Hh]eroic)(.*)$

        # lutris
        windowrule=force_tiled_state:1,tags:4,title:^([Ll]utris)(.*)$
      '';
    };
}
