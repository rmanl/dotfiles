{
  config,
  ...
}:
{
  disko.devices = {
    disk = {
      primary = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.002538554140fdb5"; # 250GB
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                passwordFile = "/tmp/disko-password"; # this is populated by bootstrap-nixos.sh
                settings = {
                  allowDiscards = true;
                };
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-L"
                    "nixos"
                    "-f"
                  ]; # force overwrite
                  subvolumes = {
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = [
                        "subvol=@log"
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
      data = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.0025385801aec34a"; # 500GB
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypteddata";
                passwordFile = "/tmp/disko-password"; # this is populated by bootstrap-nixos.sh
                settings = {
                  allowDiscards = true;
                };
                # Whether to add a boot.initrd.luks.devices entry for the this disk.
                # We only want to unlock cryptroot interactively.
                # You must have a /etc/crypttab entry set up to auto unlock the drive using a key on cryptroot (see /hosts/nixos/ghost/default.nix)
                initrdUnlock = if config.hostSpec.isMinimal then true else false;

                # subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-L"
                    "data"
                    "-f"
                  ]; # force overwrite
                  subvolumes = {
                    "@data" = {
                      mountpoint = "/mnt/data";
                      mountOptions = [
                        "defaults"
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
      games = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.0025385a0143074d"; # 1TB
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptedgames";
                passwordFile = "/tmp/disko-password"; # this is populated by bootstrap-nixos.sh
                # Whether to add a boot.initrd.luks.devices entry for the this disk.
                # We only want to unlock cryptroot interactively.
                # You must have a /etc/crypttab entry set up to auto unlock the drive using a key on cryptroot (see /hosts/linux/ghost/default.nix)
                initrdUnlock = if config.hostSpec.isMinimal then true else false;

                settings = {
                  allowDiscards = true;
                };
                # subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-L"
                    "games"
                    "-f"
                  ]; # force overwrite
                  subvolumes = {
                    "@games" = {
                      mountpoint = "/mnt/games";
                      mountOptions = [
                        "defaults"
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/var/log".neededForBoot = true;
}
