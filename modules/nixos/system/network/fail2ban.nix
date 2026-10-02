{
  flake.nixosModules.networkFail2ban = {
    services.fail2ban = {
      enable = true;
      maxretry = 3;
      bantime = "1h";

      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64 128 256";
        maxtime = "168h";
        overalljails = true;
        rndtime = "30m";
      };
    };
  };
}
