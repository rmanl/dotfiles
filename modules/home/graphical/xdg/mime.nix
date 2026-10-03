{
  flake.nixosModules.xdgMime =
    {
      host,
      lib,
      ...
    }:
    let
      inherit (host)
        browser
        chromeBrowser
        editor
        imageViewer
        mediaPlayer
        pdfViewer
        tuiFileManager
        userName
        ;
      browserApps = [ browser.appId ];
      imageViewerApps = [ imageViewer.appId ];
      videoPlayer = [ mediaPlayer.appId ];
      audioPlayer = [ mediaPlayer.appId ];

      xdgAssociations =
        type: program: list:
        builtins.listToAttrs (
          map (e: {
            name = "${type}/${e}";
            value = program;
          }) list
        );

      image = xdgAssociations "image" imageViewerApps [
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
        (xdgAssociations "application" browserApps [
          "json"
          "x-extension-htm"
          "x-extension-html"
          "x-extension-shtml"
          "x-extension-xht"
          "x-extension-xhtml"
        ])
        // (xdgAssociations "x-scheme-handler" browserApps [
          "about"
          "ftp"
          "http"
          "https"
          "unknown"
        ]);

      associations = builtins.mapAttrs (_: v: (map (e: "${e}.desktop") v)) (
        {
          "application/pdf" = [ pdfViewer.appId ];
          "text/html" = browserApps;
          "text/plain" = [ editor.appId ];
          "x-scheme-handler/chrome" = [ chromeBrowser.appId ];
          "inode/directory" = [ tuiFileManager.appId ];
        }
        // image
        // video
        // audio
        // browserTypes
      );

      formatAssoc =
        assocs:
        lib.concatStringsSep "\n" (
          lib.mapAttrsToList (mime: apps: "${mime}=${lib.concatStringsSep ";" apps}") assocs
        );
    in
    {
      hjem.users.${userName}.files.".config/mimeapps.list".text = ''
        [Default Applications]
        ${formatAssoc associations}

        [Added Associations]
        ${formatAssoc associations}
      '';
    };
}
