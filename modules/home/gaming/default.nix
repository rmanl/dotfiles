{ self, ... }:
{
  flake.nixosModules.gaming =
    { ... }:
    {
      imports = with self.nixosModules; [
        gamingGamemode
        gamingGamescope
        gamingHardware
        gamingMisc
        gamingSteam
      ];
    };
}
