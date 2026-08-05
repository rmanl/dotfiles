{
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.services.thermald;
in
{
  options.sysSpec.services.thermald = {
    enable = lib.mkEnableOption "Enable intel thermal module";
  };

  config = lib.mkIf cfg.enable {
    services.thermald = {
      enable = true;
    };
  };
}
