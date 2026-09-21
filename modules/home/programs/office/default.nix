{ self, ... }:
{
  flake.nixosModules.office =
    { ... }:
    {
      imports = with self.nixosModules; [
        officeGimp
        officeLibre
        officeZathura
      ];
    };
}
