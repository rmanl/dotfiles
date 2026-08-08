{ self, ... }:
{
  flake.nixosModules.workstation =
    { ... }:
    {
      imports = with self.nixosModules; [
        # hardware
        bluetooth
        fwupd
        pipewire

        # services
        ananicy
        fstrim
        greetd
        psd
        udisks

        # system
        fonts
        lanzaboote
        network
        nix
        settings
        ssh
        theming
        zramswap
      ];
    };
}
