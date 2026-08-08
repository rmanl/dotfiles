{
  flake.nixosModules.gtk =
    {
      config,
      host,
      inputs,
      pkgs,
      ...
    }:
    let
      inherit (config.theme)
        gtkTheme
        icons
        cursorName
        cursorSize
        fontSans
        fontSize
        ;
      inherit (host) colorTheme userName;
      fontName = "${fontSans} ${toString fontSize}";
      gtkCss = "${inputs.themes}/extra/gtk/${colorTheme}.css";
    in
    {
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
                color-scheme='prefer-dark'
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
            gtk-application-prefer-dark-mode = 1
            gtk-cursor-theme-name = ${cursorName}
            gtk-cursor-theme-size = ${toString cursorSize}
            gtk-font-name = ${fontName}
            gtk-icon-theme-name = ${icons}
          '';
          ".config/gtk-3.0/gtk.css".source = gtkCss;
          ".config/gtk-4.0/gtk.css".source = gtkCss;
        };
      };
    };
}
