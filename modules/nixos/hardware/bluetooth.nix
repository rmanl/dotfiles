{
  flake.nixosModules.bluetooth =
    {
      pkgs,
      ...
    }:
    {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = false;
        package = pkgs.bluez5-experimental;
        settings = {
          General = {
            # battery info for bluetooth devices
            Experimental = true;
          };
        };
      };
      environment.systemPackages = [ pkgs.blueman ];
    };
}
