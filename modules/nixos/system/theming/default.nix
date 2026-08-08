{
  flake.nixosModules.theming =
    {
      config,
      lib,
      pkgs,
      host,
      inputs,
      ...
    }:
    let
      inherit (host) colorTheme wallpaper;
      parseBase16 =
        path:
        let
          raw = builtins.readFile path;
          rawLines = builtins.filter builtins.isString (builtins.split "\n" raw);
          lines = builtins.filter (l: l != "") rawLines;
          parseLine =
            line:
            let
              m = builtins.match ''([a-zA-Z0-9]+): *"([^"]*)"'' line;
            in
            if m == null then
              null
            else
              {
                name = builtins.elemAt m 0;
                value = builtins.elemAt m 1;
              };
        in
        builtins.listToAttrs (builtins.filter (x: x != null) (map parseLine lines));

      base16 = parseBase16 "${inputs.themes}/extra/base16/${colorTheme}.yaml";
      withHashtag = builtins.mapAttrs (_: v: "#${v}") base16;
      defaultFonts = f: builtins.head config.fonts.fontconfig.defaultFonts.${f};
    in
    {
      imports = [ ./_options.nix ];

      colors = base16 // {
        inherit withHashtag;
      };

      theme = {
        gtkTheme = "adw-gtk3-dark";
        icons = "Papirus";
        cursorName = "capitaine-cursors";
        cursorSize = 16;
        fontSans = defaultFonts "sansSerif";
        fontMono = defaultFonts "monospace";
        fontSerif = defaultFonts "serif";
        fontEmoji = defaultFonts "emoji";
        fontSize = 12;
        opacity.terminal = 0.85;

        toRGB =
          hex:
          let
            d =
              ch:
              {
                "0" = 0;
                "1" = 1;
                "2" = 2;
                "3" = 3;
                "4" = 4;
                "5" = 5;
                "6" = 6;
                "7" = 7;
                "8" = 8;
                "9" = 9;
                "a" = 10;
                "b" = 11;
                "c" = 12;
                "d" = 13;
                "e" = 14;
                "f" = 15;
              }
              .${ch};
            h = s: lib.foldl (a: ch: a * 16 + d ch) 0 (lib.stringToCharacters s);
          in
          "${toString (h (builtins.substring 0 2 hex))}, ${toString (h (builtins.substring 2 2 hex))}, ${
            toString (h (builtins.substring 4 2 hex))
          }";

        wallpaper =
          let
            dir = ./wallpapers;
            matches = builtins.filter (lib.hasPrefix "${wallpaper}.") (
              builtins.attrNames (builtins.readDir dir)
            );
          in
          if matches == [ ] then
            throw "No wallpaper file found for '${wallpaper}' in ${toString dir}"
          else
            dir + "/${builtins.head matches}";
      };

      environment.systemPackages = with pkgs; [
        adw-gtk3
        capitaine-cursors
        (papirus-nord.override { accent = "frostblue3"; })
      ];
    };
}
