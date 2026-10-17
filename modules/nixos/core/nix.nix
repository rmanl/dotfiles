{
  flake.nixosModules.coreNix =
    {
      config,
      host,
      ...
    }:
    {
      environment.enableAllTerminfo = true;
      hardware.enableRedistributableFirmware = true;

      security.sudo.extraConfig = ''
        Defaults lecture = never # rollback results in sudo lectures after each reboot, it's somewhat useless anyway
        Defaults pwfeedback # password input feedback - makes typed password visible as asterisks
        Defaults timestamp_timeout=120 # only ask for password every 2h
        # Keep SSH_AUTH_SOCK so that pam_ssh_agent_auth.so can do its magic.
        Defaults env_keep+=SSH_AUTH_SOCK
      '';

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 20d --keep 10";
        flake = "${config.users.users.${host.userName}.home}/.config/dotfiles";
      };
    };
}
