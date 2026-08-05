{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.shell.pkgs;
in
{
  options.homeSpec.shell.pkgs = {
    enable = lib.mkEnableOption "Enable shell packages module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = with pkgs; [
      # archive
      p7zip
      unrar
      unzip
      zip

      # cli replacements
      eza # ls
      zoxide # cd
      fd # find
      ripgrep # grep
      jaq # json processor

      # system info
      cpufetch # cpu info
      fastfetch # system info
      onefetch # git repo info
      file # show file info
      duf # disk usage
      dust # disk usage

      # nix tooling
      deadnix # remove unused nix code
      nixd # nix lsp
      nixfmt # nix format
      nix-prefetch-github # fetch repo info
      statix # nix linter

      # misc tools
      gh # github cli
      ripdrag # drag pictures from terminal
      tirith # shell security
      wget2 # retrieve files over http(s)/ftp(s)
    ];
  };
}
