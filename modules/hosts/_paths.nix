host:
let
  inherit (host) userName isMultiDisk;
  home = "/home/${userName}";
  dataPath = if isMultiDisk then "/mnt/data" else "${home}/data";
in
{
  # directory created via tmpfiles, app data/media dirs
  managed = {
    cache = {
      path = "${home}/.local/cache";
      xdg = "XDG_CACHE_HOME";
    };
    stateHome = {
      path = "${home}/.local/state";
      xdg = "XDG_STATE_HOME";
    };
    dataDir = {
      path = dataPath;
      xdg = "XDG_DATA_DIR";
    };
    documents = {
      path = "${dataPath}/stuff/docs";
      xdg = "XDG_DOCUMENTS_DIR";
    };
    download = {
      path = "${home}/downloads";
      xdg = "XDG_DOWNLOAD_DIR";
    };
    music = {
      path = "${dataPath}/stuff/music";
      xdg = "XDG_MUSIC_DIR";
    };
    pictures = {
      path = "${dataPath}/stuff/pics";
      xdg = "XDG_PICTURES_DIR";
    };
    projects = {
      path = "${dataPath}/projects";
      xdg = "XDG_PROJECTS_DIR";
    };
    screenshots = {
      path = "${dataPath}/stuff/pics/screenshots";
      xdg = "XDG_SCREENSHOTS_DIR";
    };
    shared = {
      path = "${dataPath}/shared";
      xdg = "XDG_SHARED_DIR";
    };
    stuff = {
      path = "${dataPath}/stuff";
      xdg = "XDG_STUFF_DIR";
    };
    videos = {
      path = "${dataPath}/stuff/vids";
      xdg = "XDG_VIDEOS_DIR";
    };
  };

  # directory already exist some other way, only need the XDG var
  unmanaged = {
    config = {
      path = "${home}/.config";
      xdg = "XDG_CONFIG_HOME";
    };
    dataHome = {
      path = "${home}/.local/share";
      xdg = "XDG_DATA_HOME";
    };
    desktop = {
      path = home;
      xdg = "XDG_DESKTOP_DIR";
    };
    publicshare = {
      path = "/var/empty";
      xdg = "XDG_PUBLICSHARE_DIR";
    };
    templates = {
      path = "/var/empty";
      xdg = "XDG_TEMPLATES_DIR";
    };
  };

  # only used when host.isGaming is true, independent of each other
  games = {
    path = "/mnt/games";
    xdg = "XDG_GAMES_DIR";
  };
  torrent = {
    path = "/mnt/games/torrent";
    xdg = "XDG_TORRENT_DIR";
  };
}
