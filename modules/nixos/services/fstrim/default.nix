{
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.services.fstrim;
in
{
  options.sysSpec.services.fstrim = {
    enable = lib.mkEnableOption "Enable fstrim(ssd) module";
  };

  config = lib.mkIf cfg.enable {
    services.fstrim = {
      enable = true;
      interval = "weekly";
    };
  };
}
