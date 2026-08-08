{ self, ... }:
{
  flake.nixosModules.desktop =
    { ... }:
    {
      imports = with self.nixosModules; [
        workstation

        # programs
        media
        office
      ];
    };
}
