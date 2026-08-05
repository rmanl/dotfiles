{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config) hostSpec;
  inherit (hostSpec) userName;
  pubKeys = lib.filesystem.listFilesRecursive ./keys;
in
{

  users.users.${userName} = {
    name = userName;
    shell = pkgs.zsh; # default shell

    # these get placed into /etc/ssh/authorized_keys.d/<name> on nixos
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  # create ssh sockets directory for controlpaths when homemanager not loaded (i.e. isminimal)
  systemd.tmpfiles.rules =
    let
      user = config.users.users.${userName}.name;
      inherit (config.users.users.${userName}) group;
    in
    [ "d /home/${userName}/.ssh/sockets 0750 ${user} ${group} -" ];

  # no matter what environment we are in we want these tools
  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [
    just
    rsync
  ];
}
