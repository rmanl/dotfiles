{
  flake.nixosModules.coreLocale = { host, ... }: {
    time = {
      timeZone = "Europe/Amsterdam";
      hardwareClockInLocalTime = host.isDualBoot;
    };

    i18n =
      let
        defaultLocale = "en_US.UTF-8";
        nl = "nl_NL.UTF-8";
      in
      {
        inherit defaultLocale;
        extraLocaleSettings = {
          LANG = defaultLocale;
          LC_COLLATE = defaultLocale;
          LC_CTYPE = defaultLocale;
          LC_MESSAGES = defaultLocale;

          LC_ADDRESS = nl;
          LC_IDENTIFICATION = nl;
          LC_MEASUREMENT = nl;
          LC_MONETARY = nl;
          LC_NAME = nl;
          LC_NUMERIC = nl;
          LC_PAPER = nl;
          LC_TELEPHONE = nl;
          LC_TIME = defaultLocale;
        };
      };
  };
}
