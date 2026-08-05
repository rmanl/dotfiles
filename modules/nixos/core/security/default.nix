{ pkgs, ... }:
{
  security = {
    sudo.wheelNeedsPassword = false;
    polkit.enable = true;
    pam.enableUMask = true;
    rtkit.enable = true;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = with pkgs; [
        apparmor-profiles
        apparmor-utils
      ];
    };

    # allow wayland lockers to unlock the screen
    pam.services.hyprlock.text = "auth include login";
  };

  boot = {
    kernelModules = [ "tcp_bbr" ];
    kernelParams = import ./params.nix;
    kernel.sysctl = import ./sysctl.nix;
    blacklistedKernelModules = import ./modules.nix;
  };

  fileSystems =
    let
      defaults = [
        "nodev"
        "nosuid"
        "noexec"
      ];
    in
    {
      "/boot".options = defaults;
      "/var/log".options = defaults;
    };
}
