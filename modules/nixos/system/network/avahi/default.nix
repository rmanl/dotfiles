{
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.system.network.avahi;
in
{
  options.sysSpec.system.network.avahi = {
    enable = lib.mkEnableOption "Enable avahi(network discovery) module";
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        domain = true;
        userServices = true;
      };
    };
  };
}
