{
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.hardware.fwupd;
in
{
  options.sysSpec.hardware.fwupd = {
    enable = lib.mkEnableOption "Enable fwupd(firmware) module";
  };

  config = lib.mkIf cfg.enable {
    services.fwupd = {
      enable = true;
    };
  };
}
