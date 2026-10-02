{
  flake.nixosModules.pipewire = { pkgs, ... }: {
    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        wireplumber = {
          enable = true;
          extraConfig = {
            "wireplumber.profiles".main."monitor.libcamera" = "disabled";
          };
        };
      };
    };
    environment.systemPackages = with pkgs; [
      pwvucontrol
      playerctl
    ];
  };
}
