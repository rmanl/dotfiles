{
  config,
  lib,
  ...
}:
let
  cfg = config.sysSpec.services.thinkfan;
in
{
  options.sysSpec.services.thinkfan = {
    enable = lib.mkEnableOption "Enable thinkpad fancontrol module";
  };

  config = lib.mkIf cfg.enable {
    services.thinkfan = {
      enable = true;
      sensors = [
        {
          type = "tpacpi";
          query = "/proc/acpi/ibm/thermal";
        }
      ];

      fans = [
        {
          type = "tpacpi";
          query = "/proc/acpi/ibm/fan";
        }
      ];

      levels = [
        [
          0
          0
          45
        ]
        [
          1
          43
          50
        ]
        [
          2
          48
          55
        ]
        [
          3
          53
          60
        ]
        [
          4
          58
          65
        ]
        [
          5
          63
          70
        ]
        [
          7
          68
          80
        ]
        [
          127
          75
          32767
        ]
      ];
    };
  };
}
