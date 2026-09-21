{
  flake.nixosModules.officeGimp =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName}.packages = [ pkgs.gimp3 ];

    };
}
