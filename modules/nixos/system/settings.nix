{
  flake.nixosModules.settings = { pkgs, host, ... }: {
    services = {
      dbus = {
        enable = true;
        implementation = "broker";
        packages = with pkgs; [
          dconf
          gcr
        ];
      };

      udev.packages = [ pkgs.gnome-settings-daemon ];
      journald.extraConfig = ''
        SystemMaxUse=50M
        RuntimeMaxUse=10M
      '';
    };

    environment.variables = {
      EDITOR = "nvim";
      BROWSER = "${host.browser}";
    };

    environment.systemPackages = with pkgs; [
      btrfs-progs
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
        # disable getty@tty1 to prevent tty interference
        # https://github.com/nixos/nixpkgs/issues/103746
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
