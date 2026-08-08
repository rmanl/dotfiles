{
  flake.nixosModules.direnv =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName} = {
        packages = [
          pkgs.direnv
          pkgs.nix-direnv
        ];
        files.".config/direnv/direnvrc".text = ''
          source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
        '';
      };
    };
}
