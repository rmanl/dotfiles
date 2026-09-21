{ self, ... }:
{
  flake.nixosModules.zsh =
    { ... }:
    {
      imports = with self.nixosModules; [
        zshRc
        zshDevTemplates
      ];
    };
}
