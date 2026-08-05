{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.gaming.misc;
in
{
  options.homeSpec.gaming.misc = {
    enable = lib.mkEnableOption "Enable gaming misc module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = with pkgs; [
      (bottles.override { removeWarningPopup = true; }) # sandbox runtimes
      heroic # epic + gog launcher
      mangohud # display fps + perfomance
    ];
  };
}
