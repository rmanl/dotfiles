{ inputs, ... }: {
  flake.nixosModules.fonts = { pkgs, ... }: {
    fonts = {
      packages =
        (with pkgs; [
          # sans(serif) fonts
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji

          # serif
          lora
          # monospace
          hack-font
          # sans serif
          carlito # compatible with ms calibri
          source-sans
          # nerdfonts
          nerd-fonts.symbols-only
        ])
        ++ [
          (pkgs.runCommand "monolisa" { } ''
            mkdir -p $out/share/fonts/truetype
            cp -R ${inputs.monolisa}/* $out/share/fonts/truetype/
          '')
        ];

      # causes more issues than it solves
      enableDefaultPackages = false;

      # user defined fonts
      fontconfig.defaultFonts = {
        serif = [ "Lora" ];
        sansSerif = [ "Source Sans" ];
        monospace = [ "Monolisa" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
