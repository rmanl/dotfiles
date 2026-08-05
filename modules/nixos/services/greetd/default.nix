{
  config,
  lib,
  pkgs,
  perSystem,
  ...
}:
let
  cfg = config.sysSpec.services.greetd;
  session = "${config.hostSpec.hostWM} > /dev/null";
  orderOffset = config.security.pam.services.greetd.rules.session.gnome_keyring.order - 1;
in
{
  options.sysSpec.services.greetd = {
    enable = lib.mkEnableOption "Enable greetd module";
  };

  config = lib.mkIf cfg.enable {
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
          modulePath = "${perSystem.self.pam_fde_boot_pw}/lib/security/pam_fde_boot_pw.so";
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
            user = "${config.hostSpec.userName}";
          };
          default_session = with config.colors; {
            command = "${pkgs.tuigreet}/bin/tuigreet --remember --asterisks --container-padding 3 --time --time-format '%I:%M %p | %a • %h | %F' --cmd '${session}' --theme 'container=${base02};border=${base0C}'";
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

    # disable getty@tty1 to prevent tty interference
    # https://github.com/nixos/nixpkgs/issues/103746
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;
  };
}
