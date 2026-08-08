{
  flake.nixosModules.ssh =
    {
      config,
      lib,
      host,
      ...
    }:
    let
      inherit (config.users.users.${userName}) home;
      inherit (host)
        userName
        domain
        networking
        sshKeyName
        ;
      identityFiles = [ sshKeyName ];
      sshPort = networking.ports.tcp.ssh;
      vanillaHosts = import ../../hosts/_names.nix;
      vanillaHostsConfig = lib.concatMapStrings (_host: ''
        Host ${_host}
          Hostname ${_host}.${domain}
          Port ${toString sshPort}
      '') vanillaHosts;

    in
    {
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
