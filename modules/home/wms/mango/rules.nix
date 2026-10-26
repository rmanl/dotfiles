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
          m = monitor;
        in
        lib.concatStringsSep "," [
          "name:^${m.name}$"
          "width:${toString m.width}"
          "height:${toString m.height}"
          "refresh:${toString m.refresh}"
          "x:${toString m.x}"
          "y:${toString m.y}"
          "scale:${toString m.scale}"
          "vrr:${if m.vrr then "1" else "0"}"
        ];
    in
    {
      hjem.users.${userName}.files.".config/mango/rules.conf".text = ''
        # monitor
        monitor_rule=${monitorRule}
        # layouts in mango are per tag. so we'll set all tags to tile by default.
        tag_rule=id:1,layout_name:tile,no_hide:1
        tag_rule=id:2,layout_name:tile,no_hide:1
        tag_rule=id:3,layout_name:tile,no_hide:1
        tag_rule=id:4,layout_name:tile,no_hide:1
        tag_rule=id:5,layout_name:tile,no_hide:1
        tag_rule=id:6,layout_name:tile
        tag_rule=id:7,layout_name:tile
        tag_rule=id:8,layout_name:tile
        tag_rule=id:9,layout_name:tile

        # screenshot fix
        layer_rule=no_blur:1,layer_name:selection

        # dialogs
        window_rule=is_floating:1,title:^(Open File)(.*)$
        window_rule=is_floating:1,title:^(Select a File)(.*)$
        window_rule=is_floating:1,title:^(Choose wallpaper)(.*)$
        window_rule=is_floating:1,title:^(Open Folder)(.*)$
        window_rule=is_floating:1,title:^(Save As)(.*)$
        window_rule=is_floating:1,title:^(Library)(.*)$
        window_rule=is_floating:1,title:^(Accounts)(.*)$

        # nmtui network-manager
        window_rule=is_floating:1,width:800,height:600,app_id:${terminal.appId},title:^(nmtui)$

        # bluetooth
        window_rule=is_floating:1,app_id:${blueman.appId}

        # seahorse(gnome-keyring ui)
        window_rule=is_floating:1,width:800,height:600,app_id:${keyring.appId}

        # volume control
        window_rule=is_floating:1,width:800,height:600,app_id:${volumeMixer.appId}

        # pcmanfm
        window_rule=is_floating:1,width:800,height:600,app_id:${fileManager.appId}

        # imv image viewer
        window_rule=is_fullscreen:1,app_id:${imageViewer.appId}

        # proton vpn
        window_rule=width:450,height:800,app_id:${vpn.appId}

        # spotify
        window_rule=force_tiled_state:1,is_tag_silent:1,tags:5,app_id:${spotify.appId}
      ''
      + lib.optionalString isGaming ''
        # steam
        window_rule=force_tiled_state:1,is_tag_silent:1,tags:4,app_id:steam
        window_rule=is_floating:1,is_tag_silent:1,width:340,height:800,tags:4,title:^(Friends List)$,app_id:steam
        window_rule=is_floating:1,is_tag_silent:1,width:1200,height:800,tags:4,title:^(Steam Settings)$,app_id:steam

        # bottles
        window_rule=force_tiled_state:1,is_tag_silent:1,tags:4,app_id:com.usebottles.bottles

        # heroic
        window_rule=force_tiled_state:1,is_tag_silent:1,tags:4,app_id:heroic

        # transmission
        window_rule=force_tiled_state:1,is_tag_silent:1,tags:3,app_id:transmission-gtk
      '';
    };
}
