{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysSpec.system.theming;
  dark = true;
  base16 = import ./colors/${config.hostSpec.colorTheme}.nix;
  withHashtag = builtins.mapAttrs (_: v: "#${v}") base16;
  defaultFonts = f: builtins.head config.fonts.fontconfig.defaultFonts.${f};
in
{
  options.sysSpec.system.theming = {
    enable = lib.mkEnableOption "Enable theming config module";
  };

  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    colors = base16 // {
      inherit withHashtag;
    };

    theme = {
      inherit dark;
      gtkTheme = if dark then "adw-gtk3-dark" else "adw-gtk3";
      icons = if dark then "Papirus" else "Papirus-Light";
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
          url = "https://images.unsplash.com/photo-1572283046480-e990be92d301?ixlib=rb-4.0.3&q=85&fm=jpg&crop=fit&cs=srgb&w=2560";
          sha256 = "sha256-aabqRjxox+beSnfz2EzaJF5qm65GDNJXeA2iUCL0EhY=";
          ext = "jpg";
        in
        builtins.fetchurl {
          name = "wallpaper-${sha256}.${ext}";
          inherit url sha256;
        };
    };

    environment.systemPackages = with pkgs; [
      adw-gtk3
      capitaine-cursors
      (papirus-nord.override { accent = "frostblue3"; })
    ];
  };
}
