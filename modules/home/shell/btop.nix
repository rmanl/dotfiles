{
  flake.nixosModules.btop =
    {
      host,
      inputs,
      pkgs,
      ...
    }:
    let
      inherit (host) colorTheme userName;
    in
    {
      hjem.users.${userName} = {
        packages = with pkgs; [
          btop
          (writeScriptBin "htop" "exec btop")
          (writeScriptBin "top" "exec btop")
        ];
        files = {
          ".config/btop/btop.conf".text = ''
            color_theme = "${colorTheme}"
            theme_background = false
          '';
          ".config/btop/themes/${colorTheme}.theme".source =
            "${inputs.themes}/extra/btop/${colorTheme}.theme";
        };
      };
    };
}
