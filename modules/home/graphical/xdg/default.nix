{ self, ... }:
{
  flake.nixosModules.xdg =
    { ... }:
    {
      imports = with self.nixosModules; [
        xdgDirs
        xdgEnv
        xdgMime
        xdgPortal
      ];
    };
}
