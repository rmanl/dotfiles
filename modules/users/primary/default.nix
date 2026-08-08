{
  self,
  ...
}:
{
  flake.nixosModules.userPrimary =
    {
      config,
      host,
      pkgs,
      lib,
      ...
    }:
    let
      userName = host.userName;
      pubKeys = lib.filesystem.listFilesRecursive ./keys;
    in
    {
      imports = [
        self.nixosModules.userPrimaryNixos
      ];

      users.users.${userName} = {
        shell = pkgs.zsh; # default shell

        # these get placed into /etc/ssh/authorized_keys.d/<name> on nixos
        openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
      };

      # create ssh sockets directory for controlpaths when homemanager not loaded (i.e. isminimal)
      systemd.tmpfiles.rules =
        let
          user = config.users.users.${userName};
        in
        [ "d ${user.home}/.ssh/sockets 0750 ${user.name} ${user.group} -" ];

      # no matter what environment we are in we want these tools
      programs.zsh.enable = true;
      environment.systemPackages = with pkgs; [
        just
        rsync
      ];
    };
}
