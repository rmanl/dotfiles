{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.desktop.felix;
in
{
  options.homeSpec.desktop.felix = {
    enable = lib.mkEnableOption "Enable felix file manager module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName} = {
      packages = with pkgs; [
        chafa
        felix-fm
      ];
      files.".config/felix/config.yaml" = {
        generator = lib.generators.toYAML { };
        value = {
          default = "nvim";
          exec = {
            zathura = [
              "pdf"
              "epub"
            ];
            "feh -F" = [
              "jpg"
              "jpeg"
              "png"
              "gif"
              "svg"
              "hdr"
            ];
            mpv = [
              "mp4"
              "mkv"
              "webm"
            ];
            "mpv --audio-display=no" = [
              "mp3"
              "m4a"
            ];
          };
          ignore_case = true;
        };
      };
    };
  };
}
