{
  flake.nixosModules.fastfetch =
    {
      host,
      lib,
      pkgs,
      ...
    }:
    {
      hjem.users.${host.userName} = {
        packages = [ pkgs.fastfetch ];
        files.".config/fastfetch/config.jsonc" = {
          generator = (pkgs.formats.json { }).generate "config.jsonc";
          value = {
            logo.padding.top = 1;
            display.separator = " ";
            modules = [
              "title"
              "separator"
              "os"
              "host"
              "kernel"
              "uptime"
              "packages"
              "shell"
              "break"
              "wm"
              "theme"
              "icons"
              "font"
              "cursor"
              "terminal"
              "terminalfont"
              "break"
              {
                type = "display";
                format = "{width}x{height} in {inch}\", {refresh-rate} Hz";
              }
              "cpu"
              { type = "gpu"; }
              {
                type = "gpu";
                driverSpecific = true;
                format = "{3}";
                key = "GPU Driver";
              }
              "memory"
              "swap"
              "disk"
            ]
            ++ lib.optionals host.isLaptop [
              "battery"
              "poweradapter"
            ]
            ++ [
              "break"
              "locale"
              "localip"
              "break"
              "colors"
            ];
          };
        };
      };
    };
}
