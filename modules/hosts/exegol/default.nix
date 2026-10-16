{ inputs, self, ... }:
let
  disko = import ./_disko.nix;
  mkMonitor = import ../_monitors.nix;
  host = import ../_base.nix { inherit inputs; } // {
    hostName = "exegol";
    monitor = mkMonitor {
      name = "DP-2";
      width = 2560;
      height = 1440;
      refresh = 165;
      vrr = true;
    };
    wallpaper = "moon";
    isDesktop = true;
    isGaming = true;
    isMultiDisk = true;
  };
in
{
  flake = {
    nixosConfigurations.exegol = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit host inputs self; };

      modules = [ self.nixosModules.hostExegol ];
    };

    nixosModules = {
      diskoExegol = disko.module;

      hardwareExegol = {
        imports = with inputs.hardware.nixosModules; [
          ./_hardware.nix
          common-cpu-intel
          common-pc-ssd
        ];
      };

      hostExegol = { ... }: {
        imports = [
          inputs.disko.nixosModules.disko
        ]
        ++ (with self.nixosModules; [
          diskoExegol
          hardwareExegol

          core
          desktop
          gaming
          nvidia
          transmission

          # dynamic values need self to resolve at eval time
          self.nixosModules."${host.wm}Wm"
        ]);
      };
    };
  };
}
