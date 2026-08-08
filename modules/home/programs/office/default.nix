{ self, ... }:
{
  flake.nixosModules.office =
    { ... }:
    {
      imports = with self.nixosModules; [
        gimp
        libreoffice
        zathura
      ];
    };
}
