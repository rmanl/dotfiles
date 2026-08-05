{
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.gaming.gamescope;
in
{
  options.homeSpec.gaming.gamescope = {
    enable = lib.mkEnableOption "Enable gamescope module";
  };

  config = lib.mkIf cfg.enable {
    programs.gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "-f" # fullscreen
        "--rt" # realtime
        "--adaptive-sync" # vrr
        "--backend sdl"
      ];
    };
  };
}
