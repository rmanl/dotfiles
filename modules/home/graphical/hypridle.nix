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
        wm
        isLaptop
        locker
        userName
        ;
      monitor = host.monitor.name;
      runOnce = program: "pgrep ${program} || ${program}";
      lock = "loginctl lock-session";
      brillo = lib.getExe pkgs.brillo;

      dpmsCmd = lib.replaceStrings [ "%MONITOR%" ] [ monitor ];
      dpmsOff = dpmsCmd wm.dpmsOffCmd;
      dpmsOn = dpmsCmd wm.dpmsOnCmd;
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
