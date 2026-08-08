{
  flake.nixosModules.zramswap = { lib, ... }: {
    # compress half of the ram to use as swap
    zramSwap = {
      enable = lib.mkDefault true;
      algorithm = "zstd";
    };
  };
}
