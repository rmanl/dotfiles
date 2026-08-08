{
  flake.nixosModules.gimp =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName}.packages = [ pkgs.gimp3 ];

    };
}
