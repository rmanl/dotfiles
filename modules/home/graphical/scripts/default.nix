{ self, ... }:
{
  flake.nixosModules.scripts =
    { ... }:
    {
      imports = with self.nixosModules; [
        scriptsMegacmd
        scriptsMediaStatus
        scriptsPowermenu
        scriptsPrtscr
      ];
    };
}
