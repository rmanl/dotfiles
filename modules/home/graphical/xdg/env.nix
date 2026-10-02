{
  flake.nixosModules.xdgEnv =
    {
      host,
      lib,
      ...
    }:
    let
      inherit (host)
        hostWM
        isGaming
        isMultiDisk
        userName
        ;
      dataPath = if isMultiDisk then "/mnt/data" else "$HOME/data";
      wmName = lib.toUpper (builtins.substring 0 1 hostWM) + builtins.substring 1 (-1) hostWM;
    in
    {
      hjem.users.${userName} = {
        environment.sessionVariables = {
          FLAKE = "$HOME/.config/frosty";
          XDG_CACHE_HOME = "$HOME/.local/cache";
          XDG_CONFIG_HOME = "$HOME/.config";
          XDG_CURRENT_DESKTOP = wmName;
          XDG_DATA_HOME = "$HOME/.local/share";
          XDG_STATE_HOME = "$HOME/.local/state";
          XDG_DATA_DIR = "${dataPath}";
          XDG_DESKTOP_DIR = "$HOME";
          XDG_DOCUMENTS_DIR = "${dataPath}/stuff/docs";
          XDG_DOWNLOAD_DIR = "$HOME/downloads";
          XDG_MUSIC_DIR = "${dataPath}/stuff/music";
          XDG_PICTURES_DIR = "${dataPath}/stuff/pics";
          XDG_PROJECTS_DIR = "${dataPath}/projects";
          XDG_PUBLICSHARE_DIR = "/var/empty";
          XDG_SCREENSHOTS_DIR = "${dataPath}/stuff/pics/screenshots";
          XDG_SESSION_DESKTOP = wmName;
          XDG_SHARED_DIR = "${dataPath}/shared";
          XDG_STUFF_DIR = "${dataPath}/stuff";
          XDG_TEMPLATES_DIR = "/var/empty";
          XDG_VIDEOS_DIR = "${dataPath}/stuff/vids";

          # wayland backend hints for toolkits/electron
          GTK_USE_PORTAL = "1";
          GDK_BACKEND = "wayland,x11";
          MOZ_ENABLE_WAYLAND = "1";
          QT_QPA_PLATFORM = "wayland";
          NIXOS_OZONE_WL = "1";
        }
        // lib.optionalAttrs isGaming { XDG_GAMES_DIR = "/mnt/games"; };
      };
    };
}
