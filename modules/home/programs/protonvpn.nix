{
  flake.nixosModules.protonvpn =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName}.packages = [ pkgs.proton-vpn ];
    };
}
