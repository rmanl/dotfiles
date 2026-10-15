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
    in
    {
      hjem.users.${userName}.files.".config/hypr/hyprland.lua".text = ''
        hl.monitor({
          output = "${monitor.name}",
          mode = "${toString monitor.width}x${toString monitor.height}@${toString monitor.refresh}",
          position = "${toString monitor.x}x${toString monitor.y}",
          scale = ${toString monitor.scale},
          vrr = ${if monitor.vrr then "1" else "0"},
        })

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
        hl.window_rule({ match = { class = "^(steam)$", title = "^(Steam Settings)$" }, float = true, size = "600 700" })
        hl.window_rule({ match = { class = "^(com.usebottles.bottles)$" }, tile = true, workspace = "4" })
        hl.window_rule({ match = { class = "^(heroic)$" }, tile = true, workspace = "4" })
      '';
    };
}
