{
  config,
  lib,
  perSystem,
  ...
}:
let
  cfg = config.homeSpec.desktop.awww;
in
{
  options.homeSpec.desktop.awww = {
    enable = lib.mkEnableOption "Enable awww wallpaper manager module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = [ perSystem.nixpkgs-unstable.awww ];
  };
}
