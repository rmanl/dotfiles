{
  flake.nixosModules.nvidiaVaapi =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.hardware.nvidia.vaapi;
    in
    {
      options = {
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
              description = ''
                Whether to enable AV1 support. Should be disabled for GeForce 20 and earlier.
              '';
            };
          };
        };
      };

      config = lib.mkIf cfg.enable {
        environment.variables = {
          NVD_BACKEND = "direct";
        }
        // lib.optionalAttrs (cfg.maxInstances != null) {
          NVD_MAX_INSTANCES = toString cfg.maxInstances;
        }
        // lib.optionalAttrs cfg.firefox.enable {
          MOZ_DISABLE_RDD_SANDBOX = "1";
        };
      };
    };
}
