{
  flake.nixosModules.gamingGamemode =
    { host, pkgs, ... }:
    {
      programs.gamemode = {
        enable = true;
        settings.general.renice = 20;
      };
      environment.systemPackages = [ pkgs.gnomeExtensions.gamemode-shell-extension ];
      users.users.${host.userName}.extraGroups = [ "gamemode" ];
    };
}
