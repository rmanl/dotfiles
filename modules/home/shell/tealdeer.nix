{
  flake.nixosModules.tealdeer =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName} = {
        packages = [ pkgs.tealdeer ];
        files.".config/tealdeer/config.toml".text = ''
          [updates]
          auto_update = true
          auto_update_interval_hours = 720
        '';
      };
    };
}
