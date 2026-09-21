{
  flake.nixosModules.officeLibre =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName} = {
        packages = [ pkgs.libreoffice-still ];
      };
    };
}
