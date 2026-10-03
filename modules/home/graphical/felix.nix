{
  flake.nixosModules.felix =
    {
      host,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (host)
        editor
        imageViewer
        mediaPlayer
        pdfViewer
        ;
    in
    {
      hjem.users.${host.userName} = {
        packages = with pkgs; [
          chafa
          felix-fm
        ];
        files.".config/felix/config.yaml" = {
          generator = lib.generators.toYAML { };
          value = {
            default = "${editor}";
            exec = {
              "${pdfViewer}" = [
                "pdf"
                "epub"
              ];
              "${imageViewer} -f" = [
                "jpg"
                "jpeg"
                "png"
                "gif"
                "svg"
                "hdr"
              ];
              "${mediaPlayer}" = [
                "mp4"
                "mkv"
                "webm"
              ];
              "${mediaPlayer} --audio-display=no" = [
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
