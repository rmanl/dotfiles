{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysSpec.hardware.nvidia.settings;
in
{
  options.sysSpec.hardware.nvidia.settings = {
    enable = lib.mkEnableOption "Enable nvidia settings module";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      open = true;
      nvidiaSettings = true;
      powerManagement.enable = true;
      modesetting.enable = true;

      vaapi = {
        enable = true;
        firefox.enable = true;
      };

      # pinning should not be necessary anymore but keeping it here just in case
      # pin 'production' version
      # see https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nvidia-x11/default.nix
      # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      #   version = "580.105.08";
      #   sha256_64bit = "sha256-2cboGIZy8+t03QTPpp3VhHn6HQFiyMKMjRdiV2MpNHU=";
      #   openSha256 = "sha256-FGmMt3ShQrw4q6wsk8DSvm96ie5yELoDFYinSlGZcwQ=";
      #   settingsSha256 = "sha256-YvzWO1U3am4Nt5cQ+b5IJ23yeWx5ud1HCu1U0KoojLY=";
      #   persistencedSha256 = "sha256-qh8pKGxUjEimCgwH7q91IV7wdPyV5v5dc5/K/IcbruI=";
      # };
    };

    boot = {
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
        A_DRIVER_NAME = "nvidia";
        NVD_BACKEND = "direct"; # va-api hardware acceleration
        __GLX_VENDOR_ARY_NAME = "nvidia";
        __GL_GSYNC_ALLOWED = "1";
      };
    };

  };
}
