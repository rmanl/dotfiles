{
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.system.ssh;
  inherit (config.hostSpec)
    userName
    domain
    networking
    home
    ;
  identityFiles = [ "id_rma" ];
  sshPort = networking.ports.tcp.ssh;
  vanillaHosts = [
    "exegol"
    "ferrix"
    "ilum"
    "mustafar"
    "scarif"
  ];
  vanillaHostsConfig = lib.concatMapStrings (host: ''
    Host ${host}
      Hostname ${host}.${domain}
      Port ${toString sshPort}
  '') vanillaHosts;
in
{
  options.sysSpec.system.ssh = {
    enable = lib.mkEnableOption "Enable ssh module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${userName}.files = {
      ".ssh/sockets/.keep".text = "";
      ".ssh/config.d/.keep".text = "";
      ".ssh/config".text = ''
        Host *
          AddKeysToAgent no
          Compression no
          ControlMaster no
          ControlPath ~/.ssh/master-%r@%n:%p
          ControlPersist no
          ForwardAgent no
          HashKnownHosts no
          ServerAliveCountMax 3
          ServerAliveInterval 0
          UserKnownHostsFile ~/.ssh/known_hosts

        Host gitlab.com github.com codeberg.org
          User git
          AddKeysToAgent yes
          ControlMaster auto
          ControlPath ~/.ssh/sockets/S.%r@%h:%p
          ControlPersist 10m
          ForwardAgent yes
          IdentitiesOnly yes
          ${lib.concatMapStrings (f: "IdentityFile ${home}/.ssh/${f}\n        ") identityFiles}

        ${vanillaHostsConfig}
      '';
    };
  };
}
