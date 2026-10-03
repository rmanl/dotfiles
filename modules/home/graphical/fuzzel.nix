{
  flake.nixosModules.fuzzel =
    {
      host,
      config,
      inputs,
      pkgs,
      ...
    }:
    let
      inherit (host)
        colorTheme
        isDesktop
        terminal
        userName
        ;
    in
    {
      hjem.users.${userName} = {
        packages = [ pkgs.fuzzel ];
        files.".config/fuzzel/fuzzel.ini".text = with config.theme; ''
          [border]
          radius=0

          [main]
          fields=filename,name
          font=${fontMono}:size=${toString (if isDesktop then fontSize else fontSize - 4)}
          horizontal-pad=8
          line-height=16
          terminal=${terminal}
          width=50
          include=${inputs.themes}/extra/fuzzel/${colorTheme}.ini
        '';
      };
    };
}
