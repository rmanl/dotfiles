{
  flake.nixosModules.xdgDirs =
    {
      host,
      lib,
      ...
    }:
    let
      inherit (host) userName isGaming;
      paths = host.paths host;
      mkRule = p: "d ${p.path} 0755 ${userName} users";
      mkDirLine = p: ''${p.xdg}="${p.path}"'';
    in
    {
      systemd.tmpfiles.rules =
        lib.mapAttrsToList (_: mkRule) paths.managed
        ++ lib.optional isGaming (mkRule paths.games)
        ++ lib.optional isGaming (mkRule paths.torrent);

      hjem.users.${userName}.files.".config/user-dirs.dirs".text =
        lib.concatMapStringsSep "\n" mkDirLine (lib.attrValues (paths.managed // paths.unmanaged))
        + lib.optionalString isGaming ("\n" + mkDirLine paths.games + "\n" + mkDirLine paths.torrent);
    };
}
