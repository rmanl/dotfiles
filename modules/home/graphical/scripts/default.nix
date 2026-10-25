{ self, ... }:
{
  flake.nixosModules.scripts =
    { ... }:
    {
      imports = with self.nixosModules; [
        scriptsArchive
        scriptsCliphist
        scriptsCodex
        scriptsColorpick
        scriptsMegacmd
        scriptsMediaStatus
        scriptsPolkit
        scriptsPowermenu
        scriptsPrtscr
      ];
    };
}
