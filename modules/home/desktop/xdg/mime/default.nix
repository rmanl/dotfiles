{
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.desktop.xdg.mime;

  browser = [ "${config.hostSpec.browser}" ];
  imageViewer = [ "feh" ];
  videoPlayer = [ "mpv" ];
  audioPlayer = [ "mpv" ];

  xdgAssociations =
    type: program: list:
    builtins.listToAttrs (
      map (e: {
        name = "${type}/${e}";
        value = program;
      }) list
    );

  image = xdgAssociations "image" imageViewer [
    "png"
    "svg"
    "jpeg"
  ];
  video = xdgAssociations "video" videoPlayer [
    "mp4"
    "avi"
    "mkv"
  ];
  audio = xdgAssociations "audio" audioPlayer [
    "mp3"
    "flac"
    "wav"
    "aac"
  ];
  browserTypes =
    (xdgAssociations "application" browser [
      "json"
      "x-extension-htm"
      "x-extension-html"
      "x-extension-shtml"
      "x-extension-xht"
      "x-extension-xhtml"
    ])
    // (xdgAssociations "x-scheme-handler" browser [
      "about"
      "ftp"
      "http"
      "https"
      "unknown"
    ]);

  # xdg mime types
  associations = builtins.mapAttrs (_: v: (map (e: "${e}.desktop") v)) (
    {
      "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf" ];
      "text/html" = browser;
      "text/plain" = [ "nvim" ];
      "x-scheme-handler/chrome" = [ "brave" ];
      "inode/directory" = [ "fx" ];
    }
    // image
    // video
    // audio
    // browserTypes
  );
in
{
  options.homeSpec.desktop.xdg.mime = {
    enable = lib.mkEnableOption "Enable sytem xdg mime module";
  };

  config = lib.mkIf cfg.enable {
    xdg.mime = {
      addedAssociations = associations;
      defaultApplications = associations;
    };
  };
}
