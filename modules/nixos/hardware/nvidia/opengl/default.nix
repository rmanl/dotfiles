{
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.hardware.nvidia.opengl;
in
{
  options.sysSpec.hardware.nvidia.opengl = {
    enable = lib.mkEnableOption "Enable nvidia opengl fix module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.files.".nv/nvidia-application-profiles-rc".text = ''
      {
          "rules": [
              {
                  "pattern": {
                      "feature": "dso",
                      "matches": "libGL.so.1"
                  },
                  "profile": "openGL_fix"
              }
          ],
          "profiles": [
              {
                  "name": "openGL_fix",
                  "settings": [
                      {
                          "key": "GLThreadedOptimizations",
                          "value": false
                      }
                  ]
              }
          ]
      }
    '';
  };
}
