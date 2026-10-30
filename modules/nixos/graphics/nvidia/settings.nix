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

        # pinned: nvidiaPackages.stable (595.71.05) still fails to build its open
        # kernel module against linux-xanmod (missing <string.h> for strncpy in
        # os-interface.c) as of kernel 7.2.13 (confirmed 2026-10-30 via a direct
        # build of nvidiaPackages.stable.open). nixpkgs-unstable carries 595.112.07,
        # which builds fine against the same kernel. Check if nixos-26.05's
        # nvidiaPackages.stable has picked up a fixed version on the next update,
        # and drop this pin if so.
        # see https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nvidia-x11/default.nix
        package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
          version = "595.112.07";
          sha256_64bit = "sha256-Gjjs1Tii2mIypzMBhAY69Z6fyUbJCMylVb0HkJhIufA=";
          openSha256 = "sha256-nQnXGCcvo4i7eGaVft3Xc9dRUPPH0v9Zi87cfI4i/Ys=";
          settingsSha256 = "sha256-2bWSou/9J3EojhSRXBol/+yGGu2XZ6EuCptb5qXHM14=";
          persistencedSha256 = "sha256-cGMEUXN7WPu822zZDLTSu6Owj8VXG4PNmhe9oKqMMKI=";
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
