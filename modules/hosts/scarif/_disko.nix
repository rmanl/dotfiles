{
  module = (import ../_disks.nix).btrfsLuks {
    disk = "/dev/disk/by-id/nvme-eui.8ce38e0400785495";
  };
}
