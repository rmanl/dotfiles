{
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.system.network.openssh;
  sshPort = config.hostSpec.networking.ports.tcp.ssh;
  hasOptinPersistence = false;
in
{
  options.sysSpec.system.network.openssh = {
    enable = lib.mkEnableOption "Enable openssh module";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ sshPort ];

      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        StreamLocalBindUnlink = "yes";
        GatewayPorts = "clientspecified";
      };

      hostKeys = [
        {
          path = "${lib.optionalString hasOptinPersistence "/persist"}/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };

    networking.firewall.allowedTCPPorts = [ sshPort ];
  };
}
