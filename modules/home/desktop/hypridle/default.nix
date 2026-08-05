{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.desktop.hypridle;
  inherit (config.hostSpec) hostWM monitorName isLaptop;
  runOnce = program: "pgrep ${program} || ${program}";
  lock = "loginctl lock-session";
  brillo = lib.getExe pkgs.brillo;
  hyprlock = lib.getExe pkgs.hyprlock;

  dpmsOff =
    if hostWM == "hyprland" then "hyprctl dispatch dpms off" else "wlopm --off ${monitorName}";
  dpmsOn = if hostWM == "hyprland" then "hyprctl dispatch dpms on" else "wlopm --on ${monitorName}";
in
{
  options.homeSpec.desktop.hypridle = {
    enable = lib.mkEnableOption "Enable hypridle idle manager module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName} = {
      packages = with pkgs; [
        hypridle
        wlopm
      ];
      files.".config/hypr/hypridle.conf".text = ''
        general {
          after_sleep_cmd=${dpmsOn}
          before_sleep_cmd=${lock}
          inhibit_sleep=2
          lock_cmd=${runOnce "${hyprlock}"}
        }

        listener {
          on-timeout=${lock}
          timeout=910
        }

        listener {
          on-resume=${dpmsOn}
          on-timeout=${dpmsOff}
          timeout=900
        }

        listener {
          on-timeout=systemctl suspend
          timeout=2700
        }
      ''
      + lib.optionalString isLaptop ''
        listener {
          on-timeout=${brillo} -O; ${brillo} -u 500000 -S 10
          on-resume=${brillo} -I -u 250000
          timeout=890
        }
      '';
    };
  };
}
