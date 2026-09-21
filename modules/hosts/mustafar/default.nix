{ inputs, self, ... }:
let
  disko = import ./_disko.nix;
  host = import ../_base.nix { inherit inputs; } // {
    hostName = "mustafar";
    monitorName = "DP-2";
    mangoMonitor = "name:^DP-2$,width:2560,height:1440,refresh:165,x:0,y:0,scale:1,vrr:1";
    isDesktop = true;
  };
in
{
  flake = {
    nixosConfigurations.mustafar = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit host inputs self; };

      modules = [ self.nixosModules.hostMustafar ];
    };

    nixosModules = {
      diskoMustafar = disko.module;

      hardwareMustafar = {
        imports = with inputs.hardware.nixosModules; [
          ./_hardware.nix
          common-cpu-intel
          common-pc-ssd
        ];
      };

      hostMustafar = { ... }: {
        imports = [
          inputs.disko.nixosModules.disko
        ]
        ++ (with self.nixosModules; [
          diskoMustafar
          hardwareMustafar

          core
          desktop
          nvidia

          # dynamic values need self to resolve at eval time
          self.nixosModules."${host.hostWM}Wm"
        ]);
      };
    };
  };
}
