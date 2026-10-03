{
  flake.nixosModules.coreSecurity =
    { host, ... }:
    {
      security = {
        sudo.wheelNeedsPassword = false;
        polkit.enable = true;
        pam.enableUMask = true;
        rtkit.enable = true;

        # allow wayland lockers to unlock the screen
        pam.services."${host.locker}".text = "auth include login";
      };

      boot = {
        kernelModules = [ "tcp_bbr" ];
        kernelParams = import ./_params.nix;
        kernel.sysctl = import ./_sysctl.nix;
        blacklistedKernelModules = import ./_modules.nix;
      };

      fileSystems =
        let
          defaults = [
            "nodev"
            "nosuid"
            "noexec"
          ];
        in
        {
          "/boot".options = defaults;
          "/var/log".options = defaults;
        };
    };
}
