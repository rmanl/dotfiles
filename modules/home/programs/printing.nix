{
  flake.nixosModules.printing =
    {
      host,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (host) userName;
    in
    {
      hjem.users.${userName}.packages = [ pkgs.simple-scan ];
      users.users.${userName}.extraGroups = [
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

      # don't use multi-user.target: wifi printer can slow down boot
      systemd.services.ensure-printers = {
        wantedBy = lib.mkForce [ "network-online.target" ];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "15s";
          StartLimitIntervalSec = "5min";
          StartLimitBurst = 5;
        };
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
