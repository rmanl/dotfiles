{
  flake.nixosModules.tools =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName}.packages = with pkgs; [
        # archive
        p7zip
        unrar
        unzip
        zip

        # cli replacements
        duf # disk usage
        dust # disk usage
        eza # ls
        fd # find
        jaq # json processor
        procs # ps
        ripgrep # grep
        zoxide # cd

        # system info
        cpufetch # cpu info
        file # show file info
        onefetch # git repo info

        # nix tooling
        deadnix # remove unused nix code
        nix-prefetch-github # fetch repo info
        nixd # nix lsp
        nixfmt # nix format
        statix # nix linter

        # network
        gh # github cli
        wget2 # retrieve files over http(s)/ftp(s)

        # misc tools
        ripdrag # drag pictures from terminal
        tirith # shell security
        wcalc # calculator
        wl-clipboard # wayland clipboard cli (wl-copy/wl-paste)
        wlr-randr # wlroots output management
      ];
    };
}
