{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (config.hostSpec) hostWM;
in
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.self.modules.disks.exegol

    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    inputs.self.nixosModules.core
    inputs.self.nixosModules.default
    inputs.self.homeModules.default
  ];

  hostSpec = {
    hostName = "exegol";
    userName = "rma";
    handle = "rmanl";
    isNvidia = true;
    isGaming = true;
    isMultiDisk = true;
    hostWM = "mango";
    monitorName = "DP-2";
    mangoMonitor = "name:^DP-2$,width:2560,height:1440,refresh:165,x:0,y:0,scale:1,vrr:1";
    colorTheme = "nord";
    browser = "librewolf";
    inherit (inputs.nix-secrets)
      domain
      email
      location
      networking
      userFullName
      ;
  };

  sysSpec = lib.mkForce {
    hardware.enable = true;
    services.enable = true;
    system.enable = true;
  };

  homeSpec = lib.mkForce {
    apps.enable = true;
    desktop.enable = true;
    gaming.enable = true;
    shell.enable = true;
    wms.${hostWM}.enable = true;
  };

  # needed to unlock luks on secondary drives
  environment.etc.crypttab.text = lib.optionalString (!config.hostSpec.isMinimal) ''
    crypteddata /dev/disk/by-id/nvme-eui.0025385801aec34a-part1 /luks-secondary-unlock.key
    cryptedgames /dev/disk/by-id/nvme-eui.0025385a0143074d-part1 /luks-secondary-unlock.key
  '';

  nixpkgs.hostPlatform = "x86_64-linux";
}
