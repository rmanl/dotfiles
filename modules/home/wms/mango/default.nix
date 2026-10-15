{ self, ... }:
{
  flake.nixosModules.mango =
    { host, pkgs-unstable, ... }:
    {
      hjem.users.${host.userName}.packages = [
        pkgs-unstable.mango
      ];

      imports = with self.nixosModules; [
        mangoAutostart
        mangoBinds
        mangoConfig
        mangoEnv
        mangoRules
        mangoScratchpads
        mangoWmctl
      ];
    };
}
