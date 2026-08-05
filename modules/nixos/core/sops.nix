{
  inputs,
  config,
  ...
}:
let
  inherit (config.hostSpec) userName hostName home;
  sopsFolder = builtins.toString inputs.nix-secrets;
  secretsFile = "${sopsFolder}/secrets.yaml";
in
{
  # input in imported in modules/nixos/core/default.nix

  sops = {
    defaultSopsFile = "${secretsFile}";
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

      # ssh key
      "keys/ssh/rma" = {
        path = "${home}/.ssh/id_rma";
        mode = "0600";
        owner = "${userName}";
      };

      # extract password/username to /run/secrets-for-users/
      "passwords/${userName}".neededForUsers = true;

      # prevent rate limit, duplicate in home sops
      "tokens/github" = {
        mode = "0440";
        owner = "${userName}";
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
}
