{
  flake.nixosModules.udisks = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.udiskie ];
    services = {
      dbus.packages = [ pkgs.udisks2 ];
      udisks2.enable = true;
    };
  };
}
