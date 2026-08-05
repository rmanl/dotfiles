{
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.hardware.nvidia.vaapi;
  conf = config.hardware.nvidia.vaapi;
in
{
  options = {
    sysSpec.hardware.nvidia.vaapi = {
      enable = lib.mkEnableOption "Enable nvidia vaapi(acceleration) module";
    };

    hardware.nvidia.vaapi = with lib.types; {
      enable = lib.mkEnableOption "vaapi" // {
        internal = true;
      };

      maxInstances = lib.mkOption {
        type = nullOr int;
        default = null;
        description = ''
          The maximum number of concurrent instances of the driver.

          Sometimes useful for graphics cards with little VRAM.
        '';
      };

      firefox = {
        enable = lib.mkEnableOption "Firefox configuration";

        av1Support = lib.mkOption {
          type = bool;
          default = false;
          description = "Whether to enable av1 support. Should be disabled for GeForce 20 and earlier.";
        };
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      hardware.nvidia.vaapi.enable = lib.mkDefault true;
    })

    (lib.mkIf conf.enable {
      environment.variables = {
        NVD_BACKEND = "direct";
      }
      // lib.optionalAttrs (conf.maxInstances != null) {
        NVD_MAX_INSTANCES = toString conf.maxInstances;
      }
      // lib.optionalAttrs conf.firefox.enable {
        MOZ_DISABLE_RDD_SANDBOX = "1";
      };
    })
  ];
}
