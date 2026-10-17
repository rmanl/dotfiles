{
  flake.nixosModules.bash =
    {
      host,
      lib,
      pkgs,
      ...
    }:
    let
      aliasBlock = import ./_aliasBlock.nix { inherit lib host; };
    in
    {
      hjem.users.${host.userName} = {
        packages = [ pkgs.bash-completion ];
        files.".bashrc".text = ''
          source ${pkgs.bash-completion}/share/bash-completion/bash_completion

          ${aliasBlock}

          eval "$(zoxide init --cmd cd bash)"
          eval "$(direnv hook bash)"
        '';
      };
    };
}
