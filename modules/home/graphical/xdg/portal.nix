{
  flake.nixosModules.xdgPortal =
    { pkgs, ... }:
    {
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        wlr.enable = true;
        config.common = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        };
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };

      systemd.user.services.xdg-document-portal.enable = false;
    };
}
