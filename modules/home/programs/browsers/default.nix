{ self, ... }:
{
  flake.nixosModules.browsers =
    { ... }:
    {
      imports = with self.nixosModules; [
        browsersBrave
        browsersLibrewolf
      ];
    };
}
