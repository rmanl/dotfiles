{ lib, ... }:
{
  # usage:
  #   c = config.colors;
  #   c.base0D              → "8b9a97"
  #   c.withHashtag.base0D  → "#8b9a97"
  #
  #   # when both forms are needed in the same file:
  #   h = c.withHashtag;
  #   h.base0D              → "#8b9a97"
  options.colors = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = { };
    description = "Base16 color palette";
  };

  options.theme = {
    gtkTheme = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "GTK theme name (e.g. adw-gtk3-dark)";
    };
    icons = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Icon theme name (e.g. Papirus)";
    };
    cursorName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Cursor theme name";
    };
    cursorSize = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "Cursor size in pixels";
    };
    fontSans = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Sans-serif font name";
    };
    fontMono = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Monospace font name";
    };
    fontSerif = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Serif font name";
    };
    fontSize = lib.mkOption {
      type = lib.types.int;
      default = 12;
      description = "Base font size for applications";
    };
    fontEmoji = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Emoji font name";
    };
    opacity = {
      terminal = lib.mkOption {
        type = lib.types.float;
        default = 1.0;
        description = "Terminal opacity (0.0 - 1.0)";
      };
    };
    toRGB = lib.mkOption {
      type = lib.types.functionTo lib.types.str;
      default = _: "";
      description = "Convert a 6-char hex color to 'r, g, b' decimal string for use in rgba()";
    };
    wallpaper = lib.mkOption {
      type = lib.types.path;
      description = "Wallpaper to use";
    };
  };
}
