{
  flake.nixosModules.networkAvahi =
    { lib, ... }:
    {
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        publish.enable = lib.mkForce false;
      };
    };
}
