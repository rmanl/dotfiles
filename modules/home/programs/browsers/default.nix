{ self, ... }:
{
  flake.nixosModules.browsers =
    { ... }:
    {
      imports = with self.nixosModules; [
        brave
        librewolf
      ];
    };
}
