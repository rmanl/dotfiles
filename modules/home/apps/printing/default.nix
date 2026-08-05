{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.apps.printing;
in
{
  options.homeSpec.apps.printing = {
    enable = lib.mkEnableOption "Enable printing & scanning module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = [ pkgs.simple-scan ];

    users.users.${config.hostSpec.userName}.extraGroups = [
      "lp"
      "scanner"
    ];

    services = {
      printing = {
        enable = true;
        startWhenNeeded = true;
      };
      udev.packages = [ pkgs.sane-airscan ];
      ipp-usb.enable = true;
    };

    systemd.services.cups-browsed = {
      enable = false;
      unitConfig.Mask = true;
    };

    hardware = {
      # find ipps address avahi-browse -rpt _ipps._tcp | awk -F';' '{print "ipps://"$7":"$9"/ipp/print"}'
      printers = {
        ensurePrinters = [
          {
            name = "hp-deskjet";
            description = "HP DeskJet 2720e";
            location = "home";
            deviceUri = "ipps://HP50814017EF84.local:631/ipp/print";
            model = "everywhere";
          }
        ];
      };
      sane = {
        enable = true;
        extraBackends = with pkgs; [
          sane-airscan
        ];
      };
    };
  };
}
