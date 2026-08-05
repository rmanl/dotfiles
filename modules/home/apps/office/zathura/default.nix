{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.apps.office.zathura;
  inherit (config.theme) toRGB;
in
{
  options.homeSpec.apps.office.zathura = {
    enable = lib.mkEnableOption "Enable zathura module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName} = {
      packages = [ pkgs.zathura ];
      files = with config.colors; {
        ".config/zathura/zathurarc".text = ''
          set completion-bg	"rgb(${toRGB base01})"
          set completion-fg	"rgb(${toRGB base0D})"
          set completion-highlight-bg	"rgb(${toRGB base0D})"
          set completion-highlight-fg	"rgb(${toRGB base07})"
          set default-bg	"rgba(${toRGB base00}, 1.000000)"
          set default-fg	"rgb(${toRGB base01})"
          set highlight-active-color	"rgba(${toRGB base0D}, 0.500000)"
          set highlight-color	"rgba(${toRGB base0A}, 0.500000)"
          set inputbar-bg	"rgb(${toRGB base00})"
          set inputbar-fg	"rgb(${toRGB base07})"
          set notification-bg	"rgb(${toRGB base00})"
          set notification-error-bg	"rgb(${toRGB base00})"
          set notification-error-fg	"rgb(${toRGB base08})"
          set notification-fg	"rgb(${toRGB base09})"
          set notification-warning-bg	"rgb(${toRGB base00})"
          set notification-warning-fg	"rgb(${toRGB base08})"
          set recolor-darkcolor	"rgb(${toRGB base06}"
          set recolor-lightcolor	"rgb(${toRGB base00})"
          set statusbar-bg	"rgb(${toRGB base02})"
          set statusbar-fg	"rgb(${toRGB base04})"
        '';
      };
    };
  };
}
