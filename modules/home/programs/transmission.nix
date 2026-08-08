{
  flake.nixosModules.transmission =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName}.packages = [ pkgs.transmission_4-gtk ];
    };
}
