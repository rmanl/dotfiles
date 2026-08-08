{
  flake.nixosModules.felix =
    {
      host,
      pkgs,
      lib,
      ...
    }:
    {
      hjem.users.${host.userName} = {
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
