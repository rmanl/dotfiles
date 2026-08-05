{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.sysSpec.system.lanzaboote;
in
{
  options.sysSpec.system.lanzaboote = {
    enable = lib.mkEnableOption "Enable lanzaboote(secure boot) module";
  };

  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.sbctl ];

    boot = {
      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };

      # we let lanzaboote install systemd-boot
      loader.systemd-boot.enable = lib.mkForce false;
    };
  };
}
