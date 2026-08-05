{
  description = "Minimal NixOS configuration for bootstrapping systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-25.05";
    disko.url = "github:nix-community/disko";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      minimalSpecialArgs = {
        inherit inputs outputs;
        lib = nixpkgs.lib.extend (self: super: { custom = import ../lib { inherit (nixpkgs) lib; }; });
      };

      newConfig =
        name: disk: useLuks: isImp:
        (
          let
            diskSpecPath =
              if useLuks && isImp then
                ../modules/disks/btrfs-luks-impermanence/default.nix
              else if useLuks && !isImp then
                ../modules/disks/btrfs-luks/default.nix
              else
                ../modules/disks/btrfs/default.nix;
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = minimalSpecialArgs;
            modules = [
              inputs.disko.nixosModules.disko
              diskSpecPath
              {
                _module.args = {
                  inherit disk;
                };
              }
              ./minimal-configuration.nix
              ../hosts/${name}/hardware-configuration.nix

              { networking.hostName = name; }
            ];
          }
        );
    in
    {
      nixosConfigurations = {
        # host = newConfig "name" disk" "useLuks" "isImp""
        ferrix = newConfig "ferrix" "/dev/disk/by-id/nvme-eui.19255b8008440001001b448b447e9a8c" true false;
        mustafar = newConfig "mustafar" "/dev/disk/by-id/nvme-eui.002538554140fdb5" true false;
        scarif = newConfig "scarif" "/dev/disk/by-id/nvme-eui.8ce38e0400785495" true false;

        exegol = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = minimalSpecialArgs;
          modules = [
            inputs.disko.nixosModules.disko
            ../modules/disks/exegol/default.nix
            ./minimal-configuration.nix
            { networking.hostName = "exegol"; }
            ../hosts/exegol/hardware-configuration.nix
          ];
        };
      };
    };
}
