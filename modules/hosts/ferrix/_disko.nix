{
  module = (import ../_disks.nix).btrfsLuks {
    disk = "/dev/disk/by-id/nvme-eui.19255b8008440001001b448b447e9a8c";
  };
}
