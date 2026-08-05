{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.desktop.gtk;
  inherit (config.hostSpec) userName;
  inherit (config.theme)
    dark
    gtkTheme
    icons
    cursorName
    cursorSize
    fontSans
    fontSize
    toRGB
    ;

  fontName = "${fontSans} ${toString fontSize}";

  gtkCss = with config.colors.withHashtag; ''
    @define-color accent_color ${base0D};
    @define-color accent_bg_color ${base0D};
    @define-color accent_fg_color ${base00};
    @define-color destructive_color ${base08};
    @define-color destructive_bg_color ${base08};
    @define-color destructive_fg_color ${base00};
    @define-color success_color ${base0B};
    @define-color success_bg_color ${base0B};
    @define-color success_fg_color ${base00};
    @define-color warning_color ${base0E};
    @define-color warning_bg_color ${base0E};
    @define-color warning_fg_color ${base00};
    @define-color error_color ${base08};
    @define-color error_bg_color ${base08};
    @define-color error_fg_color ${base00};
    @define-color window_bg_color ${base00};
    @define-color window_fg_color ${base05};
    @define-color view_bg_color ${base00};
    @define-color view_fg_color ${base05};
    @define-color headerbar_bg_color ${base01};
    @define-color headerbar_fg_color ${base05};
    @define-color headerbar_border_color rgba(${toRGB config.colors.base01}, 0.7);
    @define-color headerbar_backdrop_color @window_bg_color;
    @define-color headerbar_shade_color rgba(0, 0, 0, 0.07);
    @define-color headerbar_darker_shade_color rgba(0, 0, 0, 0.07);
    @define-color sidebar_bg_color ${base01};
    @define-color sidebar_fg_color ${base05};
    @define-color sidebar_backdrop_color @window_bg_color;
    @define-color sidebar_shade_color rgba(0, 0, 0, 0.07);
    @define-color secondary_sidebar_bg_color @sidebar_bg_color;
    @define-color secondary_sidebar_fg_color @sidebar_fg_color;
    @define-color secondary_sidebar_backdrop_color @sidebar_backdrop_color;
    @define-color secondary_sidebar_shade_color @sidebar_shade_color;
    @define-color card_bg_color ${base01};
    @define-color card_fg_color ${base05};
    @define-color card_shade_color rgba(0, 0, 0, 0.07);
    @define-color dialog_bg_color ${base01};
    @define-color dialog_fg_color ${base05};
    @define-color popover_bg_color ${base01};
    @define-color popover_fg_color ${base05};
    @define-color popover_shade_color rgba(0, 0, 0, 0.07);
    @define-color shade_color rgba(0, 0, 0, 0.07);
    @define-color scrollbar_outline_color ${base02};
    @define-color blue_1 ${base0D};
    @define-color blue_2 ${base0D};
    @define-color blue_3 ${base0D};
    @define-color blue_4 ${base0D};
    @define-color blue_5 ${base0D};
    @define-color green_1 ${base0B};
    @define-color green_2 ${base0B};
    @define-color green_3 ${base0B};
    @define-color green_4 ${base0B};
    @define-color green_5 ${base0B};
    @define-color yellow_1 ${base0A};
    @define-color yellow_2 ${base0A};
    @define-color yellow_3 ${base0A};
    @define-color yellow_4 ${base0A};
    @define-color yellow_5 ${base0A};
    @define-color orange_1 ${base09};
    @define-color orange_2 ${base09};
    @define-color orange_3 ${base09};
    @define-color orange_4 ${base09};
    @define-color orange_5 ${base09};
    @define-color red_1 ${base08};
    @define-color red_2 ${base08};
    @define-color red_3 ${base08};
    @define-color red_4 ${base08};
    @define-color red_5 ${base08};
    @define-color purple_1 ${base0E};
    @define-color purple_2 ${base0E};
    @define-color purple_3 ${base0E};
    @define-color purple_4 ${base0E};
    @define-color purple_5 ${base0E};
    @define-color brown_1 ${base0F};
    @define-color brown_2 ${base0F};
    @define-color brown_3 ${base0F};
    @define-color brown_4 ${base0F};
    @define-color brown_5 ${base0F};
    @define-color light_1 ${base05};
    @define-color light_2 ${base05};
    @define-color light_3 ${base05};
    @define-color light_4 ${base05};
    @define-color light_5 ${base05};
    @define-color dark_1 ${base05};
    @define-color dark_2 ${base05};
    @define-color dark_3 ${base05};
    @define-color dark_4 ${base05};
    @define-color dark_5 ${base05};
  '';
in
{
  options.homeSpec.desktop.gtk = {
    enable = lib.mkEnableOption "Enable gtk module";
  };

  config = lib.mkIf cfg.enable {
    # let qt use gtk
    qt = {
      enable = true;
      platformTheme = "gtk2";
      style = "gtk2";
    };

    programs.dconf.enable = true;

    systemd.user.services.dconf-load = {
      description = "Load dconf settings";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          let
            dconfSettings = pkgs.writeText "dconf-settings" ''
              [org/gnome/desktop/interface]
              gtk-theme='${gtkTheme}'
              icon-theme='${icons}'
              cursor-theme='${cursorName}'
              cursor-size=${toString cursorSize}
              font-name='${fontName}'
              color-scheme='${if dark then "prefer-dark" else "prefer-light"}'
            '';
            script = pkgs.writeShellScript "dconf-load" ''
              ${pkgs.dconf}/bin/dconf load / < ${dconfSettings}
            '';
          in
          "${script}";
      };
    };

    hjem.users.${userName} = {
      environment.sessionVariables = {
        XCURSOR_THEME = cursorName;
        XCURSOR_SIZE = toString cursorSize;
      };

      files = {
        ".local/share/icons/default/index.theme".text = ''
          [Icon Theme]
          Name=Default
          Comment=Default cursor theme
          Inherits=${cursorName}
        '';
        ".config/gtk-3.0/settings.ini".text = ''
          [Settings]
          gtk-cursor-theme-name = ${cursorName}
          gtk-cursor-theme-size = ${toString cursorSize}
          gtk-font-name = ${fontName}
          gtk-icon-theme-name = ${icons}
          gtk-theme-name = ${gtkTheme}
        '';
        ".config/gtk-4.0/settings.ini".text = ''
          [Settings]
          gtk-application-prefer-dark-mode = ${if dark then "1" else "0"}
          gtk-cursor-theme-name = ${cursorName}
          gtk-cursor-theme-size = ${toString cursorSize}
          gtk-font-name = ${fontName}
          gtk-icon-theme-name = ${icons}
        '';
        ".config/gtk-3.0/gtk.css".text = gtkCss;
        ".config/gtk-4.0/gtk.css".text = gtkCss;
      };
    };
  };
}
