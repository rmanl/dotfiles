{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysSpec.system.settings;
in
{
  options.sysSpec.system.settings = {
    enable = lib.mkEnableOption "Enable system settings module";
  };

  config = lib.mkIf cfg.enable {
    services = {
      dbus = {
        enable = true;
        implementation = "broker";
        packages = with pkgs; [
          dconf
          gcr
        ];
      };

      udev.packages = with pkgs; [ gnome-settings-daemon ];
      journald.extraConfig = ''
        SystemMaxUse=50M
        RuntimeMaxUse=10M
      '';
    };

    environment.variables = {
      EDITOR = "nvim";
      BROWSER = "${config.hostSpec.browser}";
    };

    environment.systemPackages = with pkgs; [
      btrfs-progs
      cifs-utils
      git
      usermount
      uutils-coreutils-noprefix
      vim
    ];

    systemd = {
      settings.Manager = {
        DefaultTimeoutStopSec = "15s";
      };
      user.extraConfig = ''
        DefaultTimeoutStopSec = 15s
      '';

      services = {
        "getty@tty1".enable = false;
        "autovt@tty1".enable = false;
        "getty@tty7".enable = false;
        "autovt@tty7".enable = false;
      };
      # systemd oomd
      # fedora enables these options by default. see the 10-oomd-* files here:
      # https://src.fedoraproject.org/rpms/systemd/tree/acb90c49c42276b06375a66c73673ac3510255
      oomd.enableRootSlice = true;
    };

    programs = {
      fuse.userAllowOther = true;
      java = {
        enable = true;
        package = pkgs.jre;
      };
    };
  };
}
