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

      systemd.user.services = {
        xdg-document-portal.enable = false;
        "xdg-desktop-portal-gtk".environment = {
          GDK_BACKEND = "wayland,x11";
          GTK_USE_PORTAL = "1";
        };
      };
    };
}
