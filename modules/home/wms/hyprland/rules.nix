{
  flake.nixosModules.hyprlandRules =
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

      monitorConfig =
        let
          m = monitor;
        in
        ''
          hl.monitor({
            output = "${m.name}",
            mode = "${toString m.width}x${toString m.height}@${toString m.refresh}",
            position = "${toString m.x}x${toString m.y}",
            scale = ${toString m.scale},
            vrr = ${if m.vrr then "1" else "0"},
          })
        '';
    in
    {
      hjem.users.${userName}.files.".config/hypr/hyprland.lua".text = ''
        ${monitorConfig}

        -- dialogs
        hl.window_rule({ match = { title = "^(Open File)(.*)$" }, float = true })
        hl.window_rule({ match = { title = "^(Select a File)(.*)$" }, float = true })
        hl.window_rule({ match = { title = "^(Choose wallpaper)(.*)$" }, float = true })
        hl.window_rule({ match = { title = "^(Open Folder)(.*)$" }, float = true })
        hl.window_rule({ match = { title = "^(Save As)(.*)$" }, float = true })
        hl.window_rule({ match = { title = "^(Library)(.*)$" }, float = true })
        hl.window_rule({ match = { title = "^(Accounts)(.*)$" }, float = true })

        -- nmtui network-manager
        hl.window_rule({ match = { class = "^(${terminal.appId})$", title = "^(nmtui)$" }, float = true, size = "800 600" })

        -- bluetooth
        hl.window_rule({ match = { class = "^(${blueman.appId})$" }, float = true })

        -- seahorse (gnome-keyring ui)
        hl.window_rule({ match = { class = "^(${keyring.appId})$" }, float = true, size = "800 600" })

        -- volume control
        hl.window_rule({ match = { class = "^(${volumeMixer.appId})$" }, float = true, size = "800 600" })

        -- pcmanfm
        hl.window_rule({ match = { class = "^(${fileManager.appId})$" }, float = true, size = "800 600" })

        -- imv image viewer
        hl.window_rule({ match = { class = "^(${imageViewer.appId})$" }, fullscreen = true })

        -- proton vpn
        hl.window_rule({ match = { class = "^(${vpn.appId})$" }, size = "450 800" })

        -- spotify
        hl.window_rule({ match = { class = "^(${spotify.appId})$" }, tile = true, workspace = "5" })
      ''
      + lib.optionalString isGaming ''
        -- steam / bottles / heroic: same tile-forcing as spotify above
        hl.window_rule({ match = { class = "^(steam)$" }, tile = true, workspace = "4" })
        hl.window_rule({ match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true, size = "340 800" })
        hl.window_rule({ match = { class = "^(steam)$", title = "^(Steam Settings)$" }, float = true, size = "1200 800" })
        hl.window_rule({ match = { class = "^(com.usebottles.bottles)$" }, tile = true, workspace = "4" })
        hl.window_rule({ match = { class = "^(heroic)$" }, tile = true, workspace = "4" })

        -- transmission
        hl.window_rule({ match = { class = "^(transmission-gtk)$" }, tile = true, workspace = "3" })
      '';
    };
}
