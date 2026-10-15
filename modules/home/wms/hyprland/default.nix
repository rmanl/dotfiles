{ self, ... }:
{
  flake.nixosModules.hyprland =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName}.packages = [
        pkgs.hyprland
      ];

      imports = with self.nixosModules; [
        hyprlandAutostart
        hyprlandBinds
        hyprlandConfig
        hyprlandRules
        hyprlandScratchpads
        hyprlandWmctl
      ];
    };
}
