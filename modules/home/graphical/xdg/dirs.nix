{
  flake.nixosModules.xdgDirs =
    {
      host,
      lib,
      ...
    }:
    let
      inherit (host) userName isMultiDisk isGaming;
      home = "/home/${userName}";
      dataPath = if isMultiDisk then "/mnt/data" else "${home}/data";
    in
    {
      systemd.tmpfiles.rules = [
        "d ${home}/.local/cache 0755 ${userName} users"
        "d ${home}/.local/state 0755 ${userName} users"
        "d ${home}/downloads 0755 ${userName} users"
        "d ${dataPath} 0755 ${userName} users"
        "d ${dataPath}/projects 0755 ${userName} users"
        "d ${dataPath}/shared 0755 ${userName} users"
        "d ${dataPath}/stuff 0755 ${userName} users"
        "d ${dataPath}/stuff/docs 0755 ${userName} users"
        "d ${dataPath}/stuff/music 0755 ${userName} users"
        "d ${dataPath}/stuff/pics 0755 ${userName} users"
        "d ${dataPath}/stuff/pics/screenshots 0755 ${userName} users"
        "d ${dataPath}/stuff/vids 0755 ${userName} users"
      ]
      ++ lib.optional isGaming "d /mnt/games 0755 ${userName} users";

      hjem.users.${userName}.files.".config/user-dirs.dirs".text = ''
        XDG_CACHE_HOME="${home}/.local/cache"
        XDG_CONFIG_HOME="${home}/.config"
        XDG_DATA_DIR="${dataPath}"
        XDG_DATA_HOME="${home}/.local/share"
        XDG_STATE_HOME="${home}/.local/state"
        XDG_DESKTOP_DIR="${home}"
        XDG_DOCUMENTS_DIR="${dataPath}/stuff/docs"
        XDG_DOWNLOAD_DIR="${home}/downloads"
        XDG_MUSIC_DIR="${dataPath}/stuff/music"
        XDG_PICTURES_DIR="${dataPath}/stuff/pics"
        XDG_PROJECTS_DIR="${dataPath}/projects"
        XDG_PUBLICSHARE_DIR="/var/empty"
        XDG_SCREENSHOTS_DIR="${dataPath}/stuff/pics/screenshots"
        XDG_SHARED_DIR="${dataPath}/shared"
        XDG_STUFF_DIR="${dataPath}/stuff"
        XDG_TEMPLATES_DIR="/var/empty"
        XDG_VIDEOS_DIR="${dataPath}/stuff/vids"
      ''
      + lib.optionalString isGaming ''XDG_GAMES_DIR="/mnt/games"'';
    };
}
