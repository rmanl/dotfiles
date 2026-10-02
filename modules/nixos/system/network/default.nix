{ self, ... }:
{
  flake.nixosModules.network =
    { ... }:
    {
      imports = with self.nixosModules; [
        networkAvahi
        networkFail2ban
        networkOpenssh
        networkSettings
        networkUnbound
      ];
    };
}
