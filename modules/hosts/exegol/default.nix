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

      hostExegol = { lib, ... }: {
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

        # unlocks data/games post-boot via a keyfile on primary's root
        environment.etc.crypttab.text = lib.optionalString (!host.isMinimal) ''
          encrypteddata UUID=87a0b762-0d76-457a-a72c-d3c488a90c94 /luks-secondary-unlock.key
          encryptedgames UUID=acc32a35-3f98-4f78-b97a-b20f78ebcd11 /luks-secondary-unlock.key
        '';
      };
    };
  };
}
