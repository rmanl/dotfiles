{
  flake.nixosModules.mako =
    {
      config,
      host,
      inputs,
      pkgs,
      ...
    }:
    let
      inherit (host) colorTheme userName;
      systemIcons = "/run/current-system/sw/share/icons/${config.theme.icons}";
    in
    {
      hjem.users.${userName} = {
        packages = with pkgs; [
          libnotify
          mako
        ];
        files.".config/mako/config".text = ''
          actions=true
          anchor=top-right
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
          include=${inputs.themes}/extra/mako/${colorTheme}.ini
        '';
      };
    };
}
