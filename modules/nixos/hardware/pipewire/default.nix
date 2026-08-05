{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysSpec.hardware.pipewire;
in
{
  options.sysSpec.hardware.pipewire = {
    enable = lib.mkEnableOption "Enable pipewire module";
  };

  config = lib.mkIf cfg.enable {
    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        wireplumber = {
          enable = true;
          extraConfig = {
            "wireplumber.profiles".main."monitor.libcamera" = "disabled";
          };
        };
      };
    };
    environment.systemPackages = with pkgs; [
      pavucontrol
      playerctl
    ];
  };
}
