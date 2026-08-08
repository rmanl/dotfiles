{ inputs, self, ... }:
let
  disko = import ./_disko.nix;
  host = import ../_base.nix { inherit inputs; } // {
    hostName = "scarif";
    monitorName = "eDP-1";
    mangoMonitor = "name:^eDP-1$,width:1920,height:1080,refresh:60,x:0,y:0,scale:1,vrr:0";
    isLaptop = true;
  };
in
{
  flake = {
    nixosConfigurations.scarif = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit host inputs self; };

      modules = [ self.nixosModules.hostScarif ];
    };

    nixosModules = {
      diskoScarif = disko.module;

      hardwareScarif = {
        imports = with inputs.hardware.nixosModules; [
          ./_hardware.nix
          common-cpu-amd
          common-gpu-amd
          common-pc-ssd
        ];
      };

      hostScarif = { ... }: {
        imports = [
          inputs.disko.nixosModules.disko
        ]
        ++ (with self.nixosModules; [
          diskoScarif
          hardwareScarif

          core
          laptop
        ])
        ++ [ self.nixosModules."${host.hostWM}Wm" ];
      };
    };
  };
}
