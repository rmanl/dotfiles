{
  flake.nixosModules.bat =
    {
      host,
      pkgs,
      inputs,
      ...
    }:
    let
      inherit (host) colorTheme userName;
      themeSrc = pkgs.runCommand "bat-theme-src" { } ''
        mkdir -p $out/themes
        cp ${inputs.themes}/extra/bat/${colorTheme}.tmTheme $out/themes/${colorTheme}.tmTheme
      '';
      cacheDir = pkgs.runCommand "bat-theme-cache" { nativeBuildInputs = [ pkgs.bat ]; } ''
        mkdir -p $out
        BAT_CONFIG_DIR=${themeSrc} BAT_CACHE_PATH=$out bat cache --build
      '';
    in
    {
      hjem.users.${userName} = {
        packages = with pkgs; [
          bat # cat
          bat-extras.batdiff # diff
        ];
        files.".config/bat/config".text = ''
          --style=numbers,changes
          --theme="${colorTheme}"
          --pager="less -FR"
        '';
        environment.sessionVariables = {
          BAT_STYLE = "numbers,changes";
          BAT_CACHE_PATH = "${cacheDir}";
          MANPAGER = "sh -c 'col -bx | bat -l man -p'";
          MANROFFOPT = "-c";
        };
      };
    };
}
