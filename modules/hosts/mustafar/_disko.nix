{
  module = (import ../_disks.nix).btrfsLuks {
    disk = "/dev/disk/by-id/nvme-eui.002538554140fdb5";
  };
}
