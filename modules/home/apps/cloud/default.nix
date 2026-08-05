{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.apps.cloud;
in
{
  options.homeSpec.apps.cloud = {
    enable = lib.mkEnableOption "Enable cloud(megacmd) module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = [ pkgs.megacmd ];
    systemd.user.services.mega-cmd = {
      description = "Mega cloud storage";
      after = [ "network.target" ];
      startLimitIntervalSec = 0;
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 1;
        ExecStart = "${pkgs.megacmd}/bin/mega-cmd-server";
      };
      wantedBy = [ "default.target" ];
    };
  };
}
