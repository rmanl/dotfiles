{ self, ... }:
{
  flake.nixosModules.network =
    { ... }:
    {
      imports = with self.nixosModules; [
        networkAvahi
        networkOpenssh
        networkSettings
        networkUnbound
      ];
    };
}
