{
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.services.psd;
in
{
  options.sysSpec.services.psd = {
    enable = lib.mkEnableOption "Enable psd(browser tmpfs) module";
  };

  config = lib.mkIf cfg.enable {
    services.psd = {
      enable = true;
      resyncTimer = "10m";
    };
  };
}
