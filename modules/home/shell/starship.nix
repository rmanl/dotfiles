{
  flake.nixosModules.starship =
    { host, pkgs, ... }:
    let
      inherit (host) userName;
    in
    {
      hjem.users.${userName} = {
        packages = [ pkgs.starship ];
        environment.sessionVariables = {
          STARSHIP_CACHE = "/home/${userName}/.local/cache/starship";
        };
        files.".config/starship.toml" = {
          generator = (pkgs.formats.toml { }).generate "starship.toml";
          value = {
            scan_timeout = 30;
            command_timeout = 2000;
            add_newline = false;
            line_break.disabled = false;

            character = {
              success_symbol = "[›](bold green)";
              error_symbol = "[›](bold red)";
            };
            git_status = {
              deleted = "✗";
              modified = "✶";
              staged = "✓";
              stashed = "≡";
            };
            hostname = {
              ssh_only = true;
              disabled = false;
              format = "[$hostname](bold blue) ";
            };
            directory = {
              truncation_length = 2;
              read_only = "  ";
            };
            lua.symbol = "[ ](blue) ";
            python.symbol = "[ ](blue) ";
            rust.symbol = "[ ](red) ";
            nix_shell.symbol = "[󱄅 ](blue) ";
            golang.symbol = "[󰟓 ](blue)";
            c.symbol = "[ ](black)";
            nodejs.symbol = "[󰎙 ](yellow)";

            package.symbol = " ";
          };
        };
      };
    };
}
