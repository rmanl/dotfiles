{
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.system.zramswap;
in
{
  options.sysSpec.system.zramswap = {
    enable = lib.mkEnableOption "Enable zramswap module";
  };

  config = lib.mkIf cfg.enable {
    # compress half of the ram to use as swap
    zramSwap = {
      enable = lib.mkDefault true;
      algorithm = "zstd";
    };
  };
}
