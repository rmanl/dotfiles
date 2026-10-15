{
  flake.nixosModules.hyprpaper =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName} = {
        packages = [ pkgs.hyprpaper ];
      };
    };
}
