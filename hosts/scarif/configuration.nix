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
    inputs.self.modules.disks.btrfs-luks

    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    inputs.self.nixosModules.core
    inputs.self.nixosModules.default
    inputs.self.homeModules.default
  ];

  hostSpec = {
    hostName = "scarif";
    userName = "rma";
    handle = "rmanl";
    isLaptop = true;
    hostWM = "mango";
    monitorName = "eDP-1";
    mangoMonitor = "name:^eDP-1$,width:1920,height:1080,refresh:60,x:0,y:0,scale:1,vrr:0";
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
    apps = {
      enable = true;
      media.enable = true;
      office.enable = false;
      printing.enable = false;
      transmission.enable = false;
    };
    desktop.enable = true;
    gaming.enable = false;
    shell.enable = true;
    wms.${hostWM}.enable = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
