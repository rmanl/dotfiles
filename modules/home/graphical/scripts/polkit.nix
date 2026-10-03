{
  flake.nixosModules.scriptsPolkit =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName}.packages = [
        (pkgs.writeShellScriptBin "polkit-agent" ''
          exec ${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1
        '')
      ];
    };
}
