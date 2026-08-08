{
  flake.nixosModules.gamingGamescope = _: {
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
