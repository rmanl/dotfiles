{
  flake.nixosModules.megacmd =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName}.packages = [ pkgs.megacmd ];
      systemd.user.services.mega-cmd = {
        description = "Mega cloud storage";
        after = [ "network.target" ];
        wantedBy = [ "default.target" ];
        startLimitIntervalSec = 0;
        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = 1;
          ExecStart = "${pkgs.megacmd}/bin/mega-cmd-server";
        };
      };
    };
}
