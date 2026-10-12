{
  flake.nixosModules.hypridle =
    {
      host,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (host)
        hostWM
        isLaptop
        locker
        userName
        ;
      monitor = host.monitor.name;
      runOnce = program: "pgrep ${program} || ${program}";
      lock = "loginctl lock-session";
      brillo = lib.getExe pkgs.brillo;

      dpmsOff = if hostWM == "hyprland" then "hyprctl dispatch dpms off" else "wlopm --off ${monitor}";
      dpmsOn = if hostWM == "hyprland" then "hyprctl dispatch dpms on" else "wlopm --on ${monitor}";
    in
    {
      hjem.users.${userName} = {
        packages = with pkgs; [
          hypridle
          wlopm
        ];
        files.".config/hypr/hypridle.conf".text = ''
          general {
            after_sleep_cmd=${dpmsOn}
            before_sleep_cmd=${lock}
            inhibit_sleep=2
            lock_cmd=${runOnce "${locker}"}
          }

          listener {
            on-timeout=${lock}
            timeout=900
          }

          listener {
            on-resume=${dpmsOn}
            on-timeout=${dpmsOff}
            timeout=910
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
