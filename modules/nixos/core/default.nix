{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.core = { lib, host, ... }: {
    imports = [
      inputs.hjem.nixosModules.default
      inputs.sops-nix.nixosModules.sops
    ]
    ++ (with self.nixosModules; [
      coreBoot
      coreLocale
      coreNix
      coreRoot
      coreSecurity
      coreSops
      coreSsh
      userPrimary
    ]);

    hjem.users.${host.userName}.enable = true;
    networking.networkmanager.enable = true;

    system.stateVersion = lib.mkDefault "24.05";
  };
}
