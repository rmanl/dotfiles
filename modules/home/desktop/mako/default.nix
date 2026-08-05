{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.desktop.mako;
  systemIcons = "/run/current-system/sw/share/icons/Papirus";
in
{
  options.homeSpec.desktop.mako = {
    enable = lib.mkEnableOption "Enable mako notification module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName} = {
      packages = with pkgs; [
        libnotify
        mako
      ];
      files.".config/mako/config".text = with config.colors.withHashtag; ''
        actions=true
        anchor=top-right
        background-color=${base00}ff
        border-color=${base0B}
        border-radius=0
        border-size=1
        default-timeout=5000
        font=monospace
        format=<b>%a</b>\n%s\n%b
        height=300
        icon-path=${systemIcons}
        icons=true
        margin=12,12,6
        markup=true
        max-icon-size=48
        max-visible=3
        padding=12
        progress-color=over ${base02}
        text-color=${base05}

        [urgency=critical]
        background-color=${base00}ff
        border-color=${base08}
        text-color=${base05}

        [urgency=low]
        background-color=${base00}ff
        border-color=${base03}
        text-color=${base05}
      '';
    };
  };
}
