{ inputs, ... }: {
  flake.nixosModules.lanzaboote =
    { lib, pkgs, ... }:
    {
      imports = [
        inputs.lanzaboote.nixosModules.lanzaboote
      ];

      environment.systemPackages = [ pkgs.sbctl ];

      boot = {
        lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };

        # we let lanzaboote install systemd-boot
        loader.systemd-boot.enable = lib.mkForce false;
      };
    };
}
