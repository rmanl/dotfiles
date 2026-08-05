{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = lib.flatten [
    ../modules/hostSpec
    ../modules/nixos/core/ssh.nix
    ../modules/users/primary
    ../modules/users/primary/nixos.nix
    ../modules/users/minimal-user.nix
  ];

  hostSpec = {
    isMinimal = lib.mkForce true;
    hostName = "installer";
    userName = "rma";
  };

  fileSystems."/boot".options = [ "umask=0077" ]; # Removes permissions and security warnings.
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        # we use Git for version control, so we don't need to keep too many generations.
        configurationLimit = lib.mkDefault 3;
        # pick the highest resolution for systemd-boot's console.
        consoleMode = lib.mkDefault "max";
      };
    };
    initrd = {
      systemd = {
        enable = true;
        emergencyAccess = true; # Don't need to enter password in emergency mode
      };
      luks.forceLuksSupportInInitrd = true;
    };
    kernelParams = [
      "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
      "systemd.show_status=true"
      #"systemd.log_level=debug"
      "systemd.log_target=console"
      "systemd.journald.forward_to_console=1"
    ];
  };

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      curl
      git
      rsync
      vim
      wget
      ;
  };

  networking = {
    networkmanager.enable = true;
  };

  services = {
    qemuGuest.enable = true;
    openssh = {
      enable = true;
      ports = [ 22 ];
      settings.PermitRootLogin = "yes";
      authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
    };
  };

  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
  };
  system.stateVersion = "24.05";
}
