{
  host,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (host) userName hashedPassword;
  pubKeys = lib.filesystem.listFilesRecursive ../modules/users/primary/keys;
in
{
  users.users.${userName} = {
    isNormalUser = true;
    inherit hashedPassword;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = map builtins.readFile pubKeys;
  };

  systemd.tmpfiles.rules = [
    "d /home/${userName}/.ssh/sockets 0750 ${userName} users -"
  ];

  fileSystems."/boot".options = [ "umask=0077" ];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = lib.mkDefault 3;
        consoleMode = lib.mkDefault "max";
      };
    };
    initrd = {
      systemd = {
        enable = true;
        emergencyAccess = true;
      };
      luks.forceLuksSupportInInitrd = true;
    };
    kernelParams = [
      "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
      "systemd.show_status=true"
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

  networking.networkmanager.enable = true;

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
