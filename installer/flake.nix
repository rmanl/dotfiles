{
  description = "Minimal NixOS configuration for bootstrapping systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-26.05";
    disko.url = "github:nix-community/disko";
  };

  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    let
      newConfig =
        name:
        let
          host = import ../modules/hosts/_base.nix { inputs = null; } // {
            isMinimal = true;
            hostName = name;
          };
        in
        nixpkgs.lib.nixosSystem {
          system = host.system;
          specialArgs = {
            inherit inputs host;
          };
          modules = [
            inputs.disko.nixosModules.disko
            (import ../modules/hosts/${name}/_disko.nix).module
            ./minimal-configuration.nix
            ../modules/hosts/${name}/_hardware.nix
            { networking.hostName = name; }
          ];
        };
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs (import ../modules/hosts/_names.nix) newConfig;
    };
}
