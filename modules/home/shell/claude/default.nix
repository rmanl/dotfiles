{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.shell.claude;
in
{
  options.homeSpec.shell.claude = {
    enable = lib.mkEnableOption "Enable claude ai module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = [ pkgs.claude-code ];
  };
}
