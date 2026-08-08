{
  flake.nixosModules.libreoffice =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName} = {
        packages = [ pkgs.libreoffice-still ];
      };
    };
}
