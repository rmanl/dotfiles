{
  flake.nixosModules.gamingMisc =
    {
      host,
      pkgs,
      pkgs-unstable,
      ...
    }:
    {
      hjem.users.${host.userName}.packages = [
        (pkgs-unstable.bottles.override { removeWarningPopup = true; }) # sandbox runtimes
        pkgs.heroic # epic + gog launcher
        pkgs.mangohud # display fps + perfomance
      ];
    };
}
