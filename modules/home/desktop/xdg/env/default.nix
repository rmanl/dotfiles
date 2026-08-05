{
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.desktop.xdg.env;
  inherit (config.hostSpec) isMultiDisk isGaming;
  dataPath = if isMultiDisk then "/mnt/data" else "$HOME/data";
in
{
  options.homeSpec.desktop.xdg.env = {
    enable = lib.mkEnableOption "Enable sytem xdg env module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName} = {
      environment.sessionVariables = {
        FLAKE = "$HOME/.config/nix-config";
        XDG_CACHE_HOME = "$HOME/.local/cache";
        XDG_CONFIG_HOME = "$HOME/.config";
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
        XDG_SHARED_DIR = "${dataPath}/shared";
        XDG_STUFF_DIR = "${dataPath}/stuff";
        XDG_TEMPLATES_DIR = "/var/empty";
        XDG_VIDEOS_DIR = "${dataPath}/stuff/vids";
      }
      // lib.optionalAttrs isGaming { XDG_GAMES_DIR = "/mnt/games"; };
    };
  };
}
