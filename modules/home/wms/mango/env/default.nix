{
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.wms.mango.env;
in
{
  options.homeSpec.wms.mango.env = {
    enable = lib.mkEnableOption "Enable mango env module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName} = {
      environment.sessionVariables = {
        XDG_CURRENT_DESKTOP = "Mango";
        XDG_SESSION_DESKTOP = "Mango";
        GTK_USE_PORTAL = "1";
        GDK_BACKEND = "wayland,x11";
        MOZ_ENABLE_WAYLAND = "1";
        QT_QPA_PLATFORM = "wayland";
      };
      # prevent error message env.conf missing
      files.".config/mango/env.conf".text = "";
    };
  };
}
