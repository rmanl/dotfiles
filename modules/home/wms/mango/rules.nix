{
  flake.nixosModules.mangoRules =
    { host, lib, ... }:
    let
      inherit (host)
        blueman
        fileManager
        imageViewer
        isGaming
        keyring
        monitor
        spotify
        terminal
        userName
        volumeMixer
        vpn
        ;

      monitorRule =
        let
          inherit (monitor)
            name
            width
            height
            refresh
            x
            y
            scale
            vrr
            ;
        in
        lib.concatStringsSep "," [
          "name:^${name}$"
          "width:${toString width}"
          "height:${toString height}"
          "refresh:${toString refresh}"
          "x:${toString x}"
          "y:${toString y}"
          "scale:${toString scale}"
          "vrr:${if vrr then "1" else "0"}"
        ];
    in
    {
      hjem.users.${userName}.files.".config/mango/rules.conf".text = ''
        # monitor
        monitorrule=${monitorRule}
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
        windowrule=isfloating:1,width:800,height:600,appid:${terminal.appId},title:^(nmtui)$

        # bluetooth
        windowrule=isfloating:1,appid:${blueman.appId}

        # seahorse(gnome-keyring ui)
        windowrule=isfloating:1,width:800,height:600,appid:${keyring.appId}

        # volume control
        windowrule=isfloating:1,width:800,height:600,appid:${volumeMixer.appId}

        # pcmanfm
        windowrule=isfloating:1,width:800,height:600,appid:${fileManager.appId}

        # imv image viewer
        windowrule=isfullscreen:1,appid:${imageViewer.appId}

        # proton vpn
        windowrule=width:450,height:800,appid:${vpn.appId}

        # spotify
        windowrule=force_tiled_state:1,istagsilent:1,tags:5,appid:${spotify.appId}
      ''
      + lib.optionalString isGaming ''
        # steam
        windowrule=force_tiled_state:1,tags:4,appid:steam
        windowrule=isfloating:1,width:340,height:800,tags:4,title:^(Friends List)$,appid:steam
        windowrule=isfloating:1,width:600,height:700,tags:4,title:^(Steam Settings)$,appid:steam

        # bottles
        windowrule=force_tiled_state:1,tags:4,appid:com.usebottles.bottles

        # heroic
        windowrule=force_tiled_state:1,tags:4,appid:heroic
      '';
    };
}
