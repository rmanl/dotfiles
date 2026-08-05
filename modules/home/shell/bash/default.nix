{
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.shell.bash;
in
{
  options.homeSpec.shell.bash = {
    enable = lib.mkEnableOption "Enable bash module";
  };

  config = lib.mkIf cfg.enable {
    programs.bash = {
      completion.enable = true;
      shellAliases = import ../aliases.nix;
      interactiveShellInit = ''
        eval "$(zoxide init --cmd cd bash)"
      '';
    };
  };
}
