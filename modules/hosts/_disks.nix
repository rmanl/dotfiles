let
  espPartition = {
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
  commonSubvolumes = {
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
        "compress=zstd"
        "noatime"
      ];
    };
  };
in
{
  btrfs = { disk }: {
    disko.devices = {
      disk = {
        primary = {
          type = "disk";
          device = disk;
          content = {
            type = "gpt";
            partitions = {
              ESP = espPartition;
              root = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-L"
                    "nixos"
                    "-f"
                  ];
                  subvolumes = commonSubvolumes;
                };
              };
            };
          };
        };
      };
    };
    fileSystems."/var/log".neededForBoot = true;
  };

  btrfsLuks =
    { disk }:
    {
      disko.devices = {
        disk = {
          primary = {
            type = "disk";
            device = disk;
            content = {
              type = "gpt";
              partitions = {
                ESP = espPartition;
                luks = {
                  size = "100%";
                  content = {
                    type = "luks";
                    name = "encrypted";
                    passwordFile = "/tmp/disko-password";
                    settings = {
                      allowDiscards = true;
                    };
                    content = {
                      type = "btrfs";
                      extraArgs = [
                        "-L"
                        "nixos"
                        "-f"
                      ];
                      subvolumes = commonSubvolumes;
                    };
                  };
                };
              };
            };
          };
        };
      };
      fileSystems."/var/log".neededForBoot = true;
    };
}
