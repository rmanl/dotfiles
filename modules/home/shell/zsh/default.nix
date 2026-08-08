{ self, ... }:
{
  flake.nixosModules.zsh =
    { ... }:
    {
      imports = with self.nixosModules; [
        zshrc
        zshDevTemplates
      ];
    };
}
