{ self, inputs, ... }:
let
  inherit (import ../_base.nix { inherit inputs; })
    userName
    networking
    system
    hashedPassword
    ;
in
{
  flake = {
    nixosConfigurations.iso = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs self; };
      modules = [ self.nixosModules.hostIso ];
    };

    nixosModules.hostIso =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        imports = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
        ];

        users.users = {
          ${userName} = {
            isNormalUser = true;
            inherit hashedPassword;
            extraGroups = [ "wheel" ];
          };
          root = {
            initialHashedPassword = lib.mkForce config.users.users.${userName}.hashedPassword;
            openssh.authorizedKeys.keys = config.users.users.${userName}.openssh.authorizedKeys.keys;
          };
        };

        environment.etc.isoBuildTime.text = lib.readFile "${pkgs.runCommand "timestamp" {
          env.when = builtins.currentTime;
        } "echo -n `date -d @$when +%Y-%m-%d_%H-%M-%S` > $out"}";

        programs.bash.promptInit = ''
          export PS1="\[\033[01;32m\]\u@\h-$(cat /etc/isoBuildTime)\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
        '';

        isoImage.squashfsCompression = "zstd -Xcompression-level 3";

        nixpkgs.hostPlatform = lib.mkDefault system;

        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        services = {
          qemuGuest.enable = true;
          openssh = {
            ports = [ networking.ports.tcp.ssh ];
            settings.PermitRootLogin = lib.mkForce "yes";
          };
        };

        boot = {
          kernelPackages = pkgs.linuxPackages_latest;
          supportedFilesystems = lib.mkForce [
            "btrfs"
            "vfat"
          ];
        };

        networking.hostName = "iso";

        systemd = {
          services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
          targets = {
            sleep.enable = false;
            suspend.enable = false;
            hibernate.enable = false;
            hybrid-sleep.enable = false;
          };
        };
      };
  };
}
