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
  };
in
builtins.mapAttrs (
  name: value:
  (default // value)
  // {
    inherit name;
    __toString = self: self.name;
  }
) wms
