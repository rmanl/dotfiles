{
  flake.nixosModules.gamingMisc =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName}.packages = with pkgs; [
        (bottles.override { removeWarningPopup = true; }) # sandbox runtimes
        heroic # epic + gog launcher
        mangohud # display fps + perfomance
      ];
    };
}
