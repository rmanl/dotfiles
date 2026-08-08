{
  flake.nixosModules.psd = {
    services.psd = {
      enable = true;
      resyncTimer = "10m";
    };
  };
}
