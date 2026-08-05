{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysSpec.system.nix.lix;
in
{
  options.sysSpec.system.nix.lix = {
    enable = lib.mkEnableOption "Enable lix package manager module";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        inherit (prev.lixPackageSets.stable)
          nixpkgs-review
          nix-eval-jobs
          nix-fast-build
          colmena
          ;
      })
    ];

    nix.package = pkgs.lixPackageSets.stable.lix;
  };
}
