{ self, ... }:
{
  flake.nixosModules.mangoWm =
    { ... }:
    {
      imports = with self.nixosModules; [
        # wms
        mango

        # graphical
        awww
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
