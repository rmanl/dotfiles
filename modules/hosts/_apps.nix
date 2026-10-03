let
  mkApp =
    spec:
    if builtins.isString spec then
      {
        name = spec;
        appId = spec;
        __toString = self: self.name;
      }
    else
      {
        name = spec.name;
        appId = spec.appId or spec.name;
        __toString = self: self.name;
      };

  apps = {
    browser = "librewolf";
    chromeBrowser = "brave";
    terminal = "foot";
    launcher = "fuzzel";
    locker = "hyprlock";
    fileManager = "pcmanfm";
    tuiFileManager = "fx";
    calculator = "wcalc";
    editor = "nvim";
    imageViewer = "imv";
    mediaPlayer = "mpv";
    spotify = "spotify";
    pdfViewer = {
      name = "zathura";
      appId = "org.pwmt.zathura-pdf-mupdf";
    };
    volumeMixer = {
      name = "pwvucontrol";
      appId = "com.saivert.pwvucontrol";
    };
    keyring = {
      name = "seahorse";
      appId = "org.gnome.seahorse.Application";
    };
    blueman = {
      name = "blueman-applet";
      appId = ".blueman-manager-wrapped";
    };
    vpn = {
      name = "protonvpn-app";
      appId = ".proton-app-wrapped";
    };
  };
in
builtins.mapAttrs (_: mkApp) apps
