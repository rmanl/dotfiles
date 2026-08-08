{
  flake.nixosModules.userPrimaryNixos =
    {
      config,
      host,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (host) userName isMinimal;
      inherit (config) users sops;
      ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group users.groups) groups;

      # decrypt password to /run/secrets-for-users/ so it can be used to create the user
      sopsHashedPasswordFile = lib.optionalString (!isMinimal) sops.secrets."passwords/${userName}".path;
    in
    {
      users = {
        mutableUsers = false;

        users = {
          ${userName} = {
            home = "/home/${userName}";
            isNormalUser = true;
            hashedPasswordFile = sopsHashedPasswordFile;

            extraGroups = lib.flatten [
              "wheel"
              (ifTheyExist [
                "audio"
                "input"
                "video"
              ])
            ];
          };

          root = {
            shell = pkgs.zsh;

            inherit (users.users.${userName})
              hashedPasswordFile
              hashedPassword
              ;

            openssh.authorizedKeys.keys = users.users.${userName}.openssh.authorizedKeys.keys;
          };
        };
      };

      programs.git.enable = true;
    };
}
