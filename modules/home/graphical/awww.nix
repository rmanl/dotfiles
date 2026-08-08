{
  flake.nixosModules.awww =
    { host, pkgs-unstable, ... }:
    {
      hjem.users.${host.userName} = {
        packages = [ pkgs-unstable.awww ];
      };
    };
}
