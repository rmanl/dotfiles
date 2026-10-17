{
  flake.nixosModules.fastfetch =
    {
      host,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (host) isLaptop userName;
    in
    {
      hjem.users.${userName} = {
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
            ++ lib.optionals isLaptop [
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
