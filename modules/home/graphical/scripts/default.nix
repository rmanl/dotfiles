{ self, ... }:
{
  flake.nixosModules.scripts =
    { ... }:
    {
      imports = with self.nixosModules; [
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
