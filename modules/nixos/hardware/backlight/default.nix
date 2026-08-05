{
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.hardware.backlight;
in
{
  options.sysSpec.hardware.backlight = {
    enable = lib.mkEnableOption "Enable backlight module";
  };

  config = lib.mkIf cfg.enable {
    hardware.brillo.enable = true;
  };
}
