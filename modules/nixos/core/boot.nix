{
  flake.nixosModules.coreBoot =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      boot = {
        bootspec.enable = true;

        initrd = {
          systemd.enable = true;
          supportedFilesystems = [ "btrfs" ];
          availableKernelModules = [
            "aesni_intel"
            "ahci"
            "cryptd"
            "nvme"
            "sd_mod"
            "usb_storage"
            "xhci_pci"
          ]
          ++ config.boot.initrd.luks.cryptoModules;
        };

        tmp = {
          cleanOnBoot = true;
          useTmpfs = false;
        };

        # use latest kernel
        kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

        consoleLogLevel = 3;
        kernelParams = [
          "quiet"
          "systemd.show_status=auto"
          "rd.udev.log_level=3"
        ];

        loader = {
          systemd-boot = {
            enable = true;
            configurationLimit = 10;
            editor = false; # disable editing kernel command line
          };
          efi.canTouchEfiVariables = true;
          timeout = 0;
        };
      };

      environment.systemPackages = [ config.boot.kernelPackages.cpupower ];
    };
}
