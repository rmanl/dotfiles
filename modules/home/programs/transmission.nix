{
  flake.nixosModules.transmission =
    {
      host,
      pkgs,
      lib,
      ...
    }:
    let
      torrentPath = (host.paths host).torrent.path;
    in
    {
      hjem.users.${host.userName} = {
        packages = [ pkgs.transmission_4-gtk ];
        files.".config/transmission/settings.json" = {
          generator = lib.generators.toJSON { };
          value = {
            download-dir = torrentPath;
            watch-dir = torrentPath;
            watch-dir-enabled = true;
            rpc-enabled = false;
            inhibit-desktop-hibernation = true;
            torrent-complete-sound-enabled = false;
          };
        };
      };
    };
}
