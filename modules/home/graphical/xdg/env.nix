{
  flake.nixosModules.xdgEnv =
    {
      host,
      lib,
      ...
    }:
    let
      inherit (host) wm isGaming userName;
      home = "/home/${userName}";
      paths = host.paths host;
      toShellVar = p: lib.nameValuePair p.xdg (lib.replaceStrings [ home ] [ "$HOME" ] p.path);
      mkVars = set: lib.mapAttrs' (_: toShellVar) set;
    in
    {
      hjem.users.${userName} = {
        environment.sessionVariables =
          mkVars (paths.managed // paths.unmanaged)
          // {
            FLAKE = "$HOME/.config/dotfiles";
            XDG_CURRENT_DESKTOP = wm.xdgDesktopName;
            XDG_SESSION_DESKTOP = wm.xdgDesktopName;

            # wayland backend hints for toolkits/electron
            GTK_USE_PORTAL = "1";
            GDK_BACKEND = "wayland,x11";
            MOZ_ENABLE_WAYLAND = "1";
            QT_QPA_PLATFORM = "wayland";
            NIXOS_OZONE_WL = "1";
          }
          // lib.optionalAttrs isGaming (mkVars {
            inherit (paths) games torrent;
          });
      };
    };
}
