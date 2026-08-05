{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.hostSpec) userName;
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

  # decrypt password to /run/secrets-for-users/ so it can be used to create the user
  sopsHashedPasswordFile = lib.optionalString (
    !config.hostSpec.isMinimal
  ) config.sops.secrets."passwords/${userName}".path;
in
{
  users = {
    mutableUsers = false; # only allow declarative credentials; Required for password to be set via sops during system activation!
    #
    # ========= primary user =========
    #
    users = {
      ${userName} = {
        home = "/home/${userName}";
        isNormalUser = true;
        hashedPasswordFile = sopsHashedPasswordFile; # blank if sops is not working.

        extraGroups = lib.flatten [
          "wheel"
          (ifTheyExist [
            "audio"
            "input"
            "video"
          ])
        ];
      };

      #
      # ========= root user =========
      #
      # root's ssh key are mainly used for remote deployment, borg, and some other specific ops
      root = {
        shell = pkgs.zsh;
        inherit (config.users.users.${userName}) hashedPasswordFile;
        inherit (config.users.users.${userName}) hashedPassword; # this comes from hosts/common/optional/minimal.nix and gets overridden if sops is working
        openssh.authorizedKeys.keys = config.users.users.${userName}.openssh.authorizedKeys.keys; # root's ssh keys are mainly used for remote deployment.
      };
    };
  };

  # no matter what environment we are in we want these tools for root, and the user(s)
  programs.git.enable = true;
}
