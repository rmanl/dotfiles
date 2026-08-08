{
  flake.nixosModules.foot =
    {
      config,
      host,
      inputs,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.theme) fontMono fontSize opacity;
      inherit (host) colorTheme userName;
    in
    {
      hjem.users.${userName} = {
        packages = with pkgs; [
          foot
          libsixel
        ];
        files.".config/foot/foot.ini".text = ''
          [bell]
          notify=yes
          urgent=yes

          [colors-dark]
          alpha=${toString opacity.terminal}

          [cursor]
          beam-thickness=1
          style=beam

          [desktop-notifications]
          command=${lib.getExe pkgs.libnotify} -a ''${app-id} -i ''${app-id} ''${title} ''${body}

          [main]
          dpi-aware=no
          font=${fontMono}:size=${toString fontSize}
          horizontal-letter-offset=0
          include=${inputs.themes}/extra/foot/${colorTheme}.ini
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
