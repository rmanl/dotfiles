{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = lib.flatten [
    inputs.hjem.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    inputs.self.modules.hostSpec.default

    ./boot.nix
    ./locale.nix
    ./nix.nix
    ./security
    ./sops.nix
    ./ssh.nix
    ../../users/primary
    ../../users/primary/nixos.nix
  ];

  hjem.users.${config.hostSpec.userName}.enable = true;

  networking = {
    networkmanager.enable = true;
  };

  system.stateVersion = lib.mkDefault "24.05";
}
