{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.apps.foot;
  inherit (config.theme) fontMono fontSize opacity;
in
{
  options.homeSpec.apps.foot = {
    enable = lib.mkEnableOption "Enable foot module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName} = {
      packages = with pkgs; [
        foot
        libsixel
      ];
      files.".config/foot/foot.ini".text = with config.colors; ''
        [bell]
        notify=yes
        urgent=yes

        [colors-dark]
        alpha=${toString opacity.terminal}
        foreground=${base05}
        background=${base00}
        regular0=${base00}
        regular1=${base08}
        regular2=${base0B}
        regular3=${base0A}
        regular4=${base0D}
        regular5=${base0E}
        regular6=${base0C}
        regular7=${base05}
        bright0=${base03}
        bright1=${base08}
        bright2=${base0B}
        bright3=${base0A}
        bright4=${base0D}
        bright5=${base0E}
        bright6=${base0C}
        bright7=${base07}
        16=${base09}
        17=${base0F}
        18=${base01}
        19=${base02}
        20=${base04}
        21=${base06}

        [cursor]
        beam-thickness=1
        style=beam

        [desktop-notifications]
        command=${lib.getExe pkgs.libnotify} -a ''${app-id} -i ''${app-id} ''${title} ''${body}

        [main]
        dpi-aware=no
        font=${fontMono}:size=${toString fontSize}
        horizontal-letter-offset=0
        pad=4x4 center
        selection-target=clipboard
        vertical-letter-offset=0

        [mouse]
        hide-when-typing=yes

        [scrollback]
        indicator-format=line
        indicator-position=relative
        lines=10000
        multiplier=3

        [url]
        launch=${pkgs.xdg-utils}/bin/xdg-open ''${url}
      '';
    };
  };
}
