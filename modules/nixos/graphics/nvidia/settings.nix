{
  flake.nixosModules.nvidiaSettings =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        open = true;
        nvidiaSettings = true;
        powerManagement = {
          enable = true;
          # experimental option, set to false until stable
          kernelSuspendNotifier = false;
        };
        modesetting.enable = true;

        vaapi = {
          enable = true;
          firefox.enable = true;
        };

        # pinned: nvidiaPackages.stable (595.71.05) on nixos-26.05 fails to build its
        # open kernel module against linux-xanmod 7.2.8 (missing <string.h> for strncpy
        # in os-interface.c). nixpkgs-unstable already carries 595.104.02, which builds
        # fine against the same kernel. Check if nixos-26.05's nvidiaPackages.stable has
        # picked up a fixed version on the next update, and drop this pin if so.
        # see https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nvidia-x11/default.nix
        package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
          version = "595.104.02";
          sha256_64bit = "sha256-5CHCAuTHn1jDx/MWG75xRU67PYiTb4ggWg4yfNBMWco=";
          openSha256 = "sha256-FWk5ra2yjz8VAxAA8GXrSoeBj/XC1BKvsKsBKR09joE=";
          settingsSha256 = "sha256-4Kxro6tvI5aX4nu2RspgyBsW+Jq3/VYjSAS5UGdzTCU=";
          persistencedSha256 = "sha256-JsMLPqJuZwAtHngsQODMsmgO7F2tVkQ2arc7fYa2bwo=";
        };
      };

      boot = {
        kernelPackages = lib.mkForce pkgs.linuxPackages_xanmod_stable;
        kernelParams = [
          "nvidia_drm.fbdev=1"
          "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
        ];

        extraModprobeConfig =
          "options nvidia "
          + lib.concatStringsSep " " [
            "NVreg_UsePageAttributeTable=1"
            "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"
          ];
      };

      environment = {
        systemPackages = [ pkgs.nvtopPackages.nvidia ];
        variables = {
          GBM_BACKEND = "nvidia-drm";
          LIBVA_DRIVER_NAME = "nvidia";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          __GL_GSYNC_ALLOWED = "1";
        };
      };
    };
}
