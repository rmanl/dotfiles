{
  flake.nixosModules.greetd =
    {
      config,
      lib,
      pkgs,
      host,
      ...
    }:
    let
      inherit (host) hostWM userName;
      session = "${hostWM} > /dev/null";
      orderOffset = config.security.pam.services.greetd.rules.session.gnome_keyring.order - 1;
    in
    {
      environment.systemPackages = with pkgs; [
        tuigreet
        libsecret
        gnome-keyring
        libgnome-keyring
      ];

      programs.seahorse.enable = true;

      # required for pam_fde_boot_pw
      boot.initrd.systemd.enable = true;

      security.pam.services = {
        greetd = {
          enableGnomeKeyring = true;

          # add pam_fde_boot_pw rule before gnome_keyring in the session phase
          rules.session.fde_boot_pw = {
            order = orderOffset;
            enable = true;
            control = "optional";
            modulePath = "${pkgs.callPackage ./_pam_fde_boot_pw.nix { }}/lib/security/pam_fde_boot_pw.so";
            args = [ "inject_for=gkr" ];
          };
        };

        greetd-password.enableGnomeKeyring = true;
        login.enableGnomeKeyring = true;
        gdm-password.enableGnomeKeyring = true;
      };

      services = {
        gnome.gnome-keyring.enable = true;

        greetd = {
          enable = true;
          settings = {
            initial_session = {
              command = session;
              user = "${userName}";
            };
            default_session = with config.colors; {
              command = "${pkgs.tuigreet}/bin/tuigreet --remember --asterisks --container-padding 3 --time --time-format '%I:%M %p | %a • %h | %F' --cmd ${lib.escapeShellArg session} --theme 'container=${base02};border=${base0C}'";
              user = "greeter";
            };
          };
        };
      };

      systemd.services.greetd.serviceConfig = {
        Type = "idle"; # don't change
        StandardInput = "tty";
        StandardOutput = "tty";
        StandardError = "journal";
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
        KeyringMode = lib.mkForce "inherit";
      };
    };
}
