{ self, ... }:
{
  flake.nixosModules.laptop =
    { ... }:
    {
      imports = with self.nixosModules; [
        workstation

        # programs
        mediaCommon

        # hardware
        backlight

        # services
        power
      ];
    };
}
