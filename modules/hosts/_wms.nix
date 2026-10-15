let
  default = {
    dpmsOnCmd = "wlopm --on %MONITOR%";
    dpmsOffCmd = "wlopm --off %MONITOR%";
  };
  wms = {
    mango = {
      xdgDesktopName = "mango";
      portalBackend = "wlr";
    };
    hyprland = {
      xdgDesktopName = "Hyprland";
      portalBackend = "hyprland";
      dpmsOnCmd = "hyprctl dispatch dpms on";
      dpmsOffCmd = "hyprctl dispatch dpms off";
      startCmd = "start-hyprland";
    };
  };
in
builtins.mapAttrs (
  name: value:
  (default // value)
  // {
    inherit name;
    startCmd = value.startCmd or name;
    __toString = self: self.name;
  }
) wms
