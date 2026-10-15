{ self, ... }:
{
  flake.nixosModules.hyprlandWm =
    { pkgs, ... }:
    {
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

      imports = with self.nixosModules; [
        # wms
        hyprland

        # graphical
        hyprpaper
        felix
        fuzzel
        gtk
        hypridle
        hyprlock
        mako
        scripts
        waybar
        xdg

        # shell
        bash
        bat
        btop
        direnv
        fastfetch
        git
        tealdeer
        tools
        starship
        zsh
        claude

        # programs
        browsers
        foot
        megacmd
        nvim
        pcmanfm
        printing
        protonvpn
      ];
    };
}
