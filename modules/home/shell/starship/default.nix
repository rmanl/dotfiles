{
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.shell.starship;
in
{
  options.homeSpec.shell.starship = {
    enable = lib.mkEnableOption "Enable starship prompt module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName} = {
      environment.sessionVariables = {
        STARSHIP_CACHE = "${config.hostSpec.home}/.local/cache/starship";
      };
    };

    programs.starship = {
      enable = true;
      settings = {
        scan_timeout = 2;
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
          read_only = "  ";
        };
        lua.symbol = "[ ](blue) ";
        python.symbol = "[ ](blue) ";
        rust.symbol = "[ ](red) ";
        nix_shell.symbol = "[󱄅 ](blue) ";
        golang.symbol = "[󰟓 ](blue)";
        c.symbol = "[ ](black)";
        nodejs.symbol = "[󰎙 ](yellow)";

        package.symbol = " ";
      };
    };
  };
}
