{
  flake.nixosModules.xdgPortal =
    { host, pkgs, ... }:
    {
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        wlr.enable = host.wm.portalBackend == "wlr";
        config.common = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.Screenshot" = [ host.wm.portalBackend ];
          "org.freedesktop.impl.portal.ScreenCast" = [ host.wm.portalBackend ];
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
