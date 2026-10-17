{
  flake.nixosModules.xdgPortal =
    { host, pkgs, ... }:
    let
      inherit (host.wm) portalBackend;
    in
    {
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        wlr.enable = portalBackend == "wlr";
        config.common = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.Screenshot" = [ portalBackend ];
          "org.freedesktop.impl.portal.ScreenCast" = [ portalBackend ];
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
