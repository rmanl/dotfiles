{ self, ... }:
{
  flake.nixosModules.nix =
    { ... }:
    {
      imports = with self.nixosModules; [
        nixExtra
        nixLix
        nixPkgs
        nixSubstituters
      ];
    };
}
