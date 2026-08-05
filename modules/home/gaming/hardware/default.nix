{
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.gaming.hardware;
in
{
  options.homeSpec.gaming.hardware = {
    enable = lib.mkEnableOption "Enable gaming hardware module";
  };

  config = lib.mkIf cfg.enable {
    hardware = {
      xpadneo.enable = true; # xbox controller bt support
      xone.enable = true; # xbox controller dongle
    };
    boot.kernelModules = [ "xpad" ];
  };
}
