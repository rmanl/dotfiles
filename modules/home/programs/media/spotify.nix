_: {
  flake.nixosModules.mediaSpotify =
    {
      host,
      pkgs,
      inputs,
      ...
    }:
    let
      inherit (host) colorTheme userName;
      colorIni = "${inputs.themes}/extra/spotify/${colorTheme}.ini";
      adblock = pkgs.fetchFromGitHub {
        owner = "rxri";
        repo = "spicetify-extensions";
        rev = "64cb2b8c235b13cf943e4c265c19199f69e5d170";
        hash = "sha256-gzmKE1wMPIBrtJ2NhkaFlx8Q8wCGjDjALhH8TewVMyQ=";
      };
      autoSkip = pkgs.fetchFromGitHub {
        owner = "daksh2k";
        repo = "Spicetify-stuff";
        rev = "988473bca46c25f644747acc1f31ddd2c950be5c";
        hash = "sha256-sCC6U9D7/0cCV9HiDDlHK5KZKs+TiqNvYNuS8qh2PQk=";
      };
      autoVolume = pkgs.fetchFromGitHub {
        owner = "amanharwara";
        repo = "spicetify-autoVolume";
        rev = "d7f7962724b567a8409ef2898602f2c57abddf5a";
        hash = "sha256-WquDmeaj+7M8DzGuHYOJgF6ifcs3vj3gIciZMaRQ3t4=";
      };
      hidePodcasts = pkgs.fetchFromGitHub {
        owner = "theRealPadster";
        repo = "spicetify-hide-podcasts";
        rev = "70209bfe18728d630363df3a32d813514aa4bcbc";
        hash = "sha256-3cDqy2h2djYTrX0OABRpjZBjfMMLlhXH1WdxAolqM2I=";
      };
      history = pkgs.fetchFromGitHub {
        owner = "einzigartigerName";
        repo = "spicetify-history";
        rev = "577e34f364127f18d917d2fe2e8c8f2a1af9f6ae";
        hash = "sha256-ORG1oNvMTJxrI3spfAuN+pCKTKvQfhqUIYT9NM1yZTs=";
      };
      spicedSpotify = pkgs.spotify.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.spicetify-cli ];
        postInstall = (old.postInstall or "") + ''
          export SPICETIFY_CONFIG="$TMPDIR/spicetify-config"
          mkdir -p "$SPICETIFY_CONFIG"/{Extensions,CustomApps,Themes/Default}
          cp ${adblock}/adblock/adblock.js "$SPICETIFY_CONFIG/Extensions/adblock.js"
          cp ${autoSkip}/Extensions/auto-skip/dist/autoSkip.js "$SPICETIFY_CONFIG/Extensions/autoSkip.js"
          cp ${autoVolume}/autoVolume.js "$SPICETIFY_CONFIG/Extensions/autoVolume.js"
          cp ${hidePodcasts}/hidePodcasts.js "$SPICETIFY_CONFIG/Extensions/hidePodcasts.js"
          cp ${history}/historyShortcut.js "$SPICETIFY_CONFIG/Extensions/historyShortcut.js"
          cp ${pkgs.spicetify-cli.src}/Extensions/shuffle+.js "$SPICETIFY_CONFIG/Extensions/shuffle+.js"
          cp ${colorIni} "$SPICETIFY_CONFIG/Themes/Default/color.ini"
          touch "$SPICETIFY_CONFIG/prefs"
          cat > "$SPICETIFY_CONFIG/config-xpui.ini" <<CFGEOF
          [Setting]
          spotify_path = $out/share/spotify
          prefs_path = $SPICETIFY_CONFIG/prefs
          current_theme = Default
          color_scheme = custom
          inject_css = 1
          inject_theme_js = 1
          replace_colors = 1
          overwrite_assets = 1

          [AdditionalOptions]
          extensions = adblock.js|autoSkip.js|autoVolume.js|hidePodcasts.js|historyShortcut.js|shuffle+.js
          custom_apps =

          [Backup]

          [Patch]

          [Preprocesses]
          CFGEOF
          HOME="$TMPDIR/home" ${pkgs.spicetify-cli}/bin/spicetify --no-restart backup apply
        '';
      });
    in
    {
      hjem.users.${userName}.packages = [ spicedSpotify ];
    };
}
