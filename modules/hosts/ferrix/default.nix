{ inputs, self, ... }:
let
  disko = import ./_disko.nix;
  mkMonitor = import ../_monitors.nix;
  host = import ../_base.nix { inherit inputs; } // {
    hostName = "ferrix";
    monitor = mkMonitor {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      refresh = 60;
    };
    isLaptop = true;
  };
in
{
  flake = {
    nixosConfigurations.ferrix = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit host inputs self; };
      modules = [ self.nixosModules.hostFerrix ];
    };

    nixosModules = {
      diskoFerrix = disko.module;

      hardwareFerrix = {
        imports = [
          ./_hardware.nix
          inputs.hardware.nixosModules.lenovo-thinkpad-t480s
        ];
      };

      hostFerrix = { ... }: {
        imports = [
          inputs.disko.nixosModules.disko
        ]
        ++ (with self.nixosModules; [
          diskoFerrix
          hardwareFerrix

          core
          laptop
          thermald
          thinkfan
          throttled
          intel

          # dynamic values need self to resolve at eval time
          self.nixosModules."${host.wm}Wm"
        ]);
      };
    };
  };
}
