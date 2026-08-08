{
  flake.nixosModules.gamingHardware = _: {
    hardware = {
      xpadneo.enable = true; # xbox controller bt support
      xone.enable = true; # xbox controller dongle
    };
    boot.kernelModules = [ "xpad" ];
  };
}
