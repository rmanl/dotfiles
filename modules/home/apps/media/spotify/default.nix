{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.apps.media.spotify;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.homeSpec.apps.media.spotify = {
    enable = lib.mkEnableOption "Enable spotify module";
  };

  imports = [ inputs.spicetify-nix.nixosModules.spicetify ];

  config = lib.mkIf cfg.enable {
    programs.spicetify = {
      enable = true;

      colorScheme = "custom";
      customColorScheme = with config.colors; {
        text = "${base07}";
        subtext = "${base05}";
        sidebar-text = "${base07}";
        main = "${base00}";
        sidebar = "${base00}";
        player = "${base00}";
        card = "${base00}";
        shadow = "${base00}";
        selected-row = "${base05}";
        button = "${base08}";
        button-active = "${base0F}";
        button-disabled = "${base04}";
        tab-active = "${base09}";
        notification = "${base0C}";
        notification-error = "${base09}";
        misc = "${base09}";
      };

      enabledExtensions = with spicePkgs.extensions; [
        adblock
        autoSkip
        autoSkip
        autoVolume
        bookmark
        copyToClipboard
        fullAppDisplay
        fullAppDisplayMod
        groupSession
        hidePodcasts
        history
        keyboardShortcut
        loopyLoop
        phraseToPlaylist
        savePlaylists
        shuffle
        skipStats
        trashbin
        wikify
      ];
      enabledCustomApps = with spicePkgs.apps; [
        reddit
        lyricsPlus
        localFiles
      ];
    };
  };
}
