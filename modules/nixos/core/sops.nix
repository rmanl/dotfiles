{ inputs, ... }:
{
  flake.nixosModules.coreSops =
    {
      config,
      host,
      ...
    }:
    let
      inherit (host) userName hostName sshKeyName;
      inherit (config.users.users.${userName}) home;

      sopsFolder = builtins.toString inputs.nix-secrets;
      secretsFile = "${sopsFolder}/secrets.yaml";
    in
    {
      sops = {
        defaultSopsFile = secretsFile;
        validateSopsFiles = false;

        age = {
          sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        };

        secrets = {
          "keys/age/${userName}_${hostName}" = {
            owner = config.users.users.${userName}.name;
            inherit (config.users.users.${userName}) group;
            path = "${home}/.config/sops/age/keys.txt";
          };

          "keys/ssh/${userName}" = {
            path = "${home}/.ssh/${sshKeyName}";
            mode = "0600";
            owner = userName;
          };

          "passwords/${userName}".neededForUsers = true;

          "tokens/github" = {
            mode = "0440";
            owner = userName;
          };
        };
      };

      system.activationScripts.sopsSetAgeKeyOwnership =
        let
          ageFolder = "${home}/.config/sops/age";
          user = config.users.users.${userName}.name;
          group = config.users.users.${userName}.group;
        in
        ''
          mkdir -p ${ageFolder} || true
          chown -R ${user}:${group} ${home}/.config
        '';
    };
}
