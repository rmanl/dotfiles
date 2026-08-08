{
  module =
    { host, lib, ... }:
    lib.recursiveUpdate
      ((import ../_disks.nix).btrfsLuks {
        disk = "/dev/disk/by-id/nvme-eui.002538554140fdb5"; # 250GB
      })
      {
        disko.devices.disk = {
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
                    name = "encrypteddata";
                    passwordFile = "/tmp/disko-password";
                    settings = {
                      allowDiscards = true;
                    };
                    initrdUnlock = if host.isMinimal then true else false;
                    content = {
                      type = "btrfs";
                      extraArgs = [
                        "-L"
                        "data"
                        "-f"
                      ];
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
                    name = "encryptedgames";
                    passwordFile = "/tmp/disko-password";
                    initrdUnlock = if host.isMinimal then true else false;
                    settings = {
                      allowDiscards = true;
                    };
                    content = {
                      type = "btrfs";
                      extraArgs = [
                        "-L"
                        "games"
                        "-f"
                      ];
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
}
