{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.desktop.fuzzel;
in
{
  options.homeSpec.desktop.fuzzel = {
    enable = lib.mkEnableOption "Enable fuzzel launcher module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName} = {
      packages = [ pkgs.fuzzel ];
      files = {
        ".config/fuzzel/fuzzel.ini".text =
          with config.colors;
          with config.theme;
          ''
            [border]
            radius=0

            [colors]
            background=${base00}ff
            border=${base0D}ff
            counter=${base06}ff
            input=${base05}ff
            match=${base0A}ff
            placeholder=${base03}ff
            prompt=${base0C}ff
            selection=${base02}ff
            selection-match=${base0A}ff
            selection-text=${base05}ff
            text=${base05}ff

            [main]
            fields=filename,name
            font=${fontMono}:size=${toString (if config.hostSpec.isLaptop then fontSize - 4 else fontSize)}
            horizontal-pad=8
            line-height=16
            terminal=${lib.getExe pkgs.foot}
            width=50
          '';
      };
    };
  };
}
