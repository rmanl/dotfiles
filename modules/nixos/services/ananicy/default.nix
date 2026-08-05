{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysSpec.services.ananicy;
in
{
  options.sysSpec.services.ananicy = {
    enable = lib.mkEnableOption "Enable cpu scheduler module";
  };

  config = lib.mkIf cfg.enable {
    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
    };
  };
}
