# https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.apps.browsers.librewolf;
  policies = {
    policies = {
      ColorScheme = 2;
      WebsiteFilter = { };
      DefaultSearchService = "DuckDuckGo";
      DefaultSearchServicePrivate = "DuckDuckGo";
      DisableAccounts = false;
      DisableFirefoxAccounts = true;
      DisableFirefoxScreenshots = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisplayBookmarksToolbar = "never";
      DisplayMenuBar = "default-off";
      DontCheckDefaultBrowser = true;
      EnableTrackingProtection = {
        Cryptomining = true;
        Fingerprinting = true;
        Locked = true;
        Value = true;
      };
      EncryptedMediaExtensions = {
        Enabled = true;
        Locked = false;
      };
      NoDefaultBookmarks = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      SanitizeOnShutdown = {
        Cache = true;
        Cookies = true;
        Downloads = true;
        FormData = true;
        History = true;
        Sessions = true;
        SiteSettings = false;
        OfflineApps = true;
      };
      SearchBar = "unified";
      SearchEngines = {
        Remove = [
          "Google"
          "Bing"
          "Perplexity"
        ];
      };
      Preferences = {
        "sidebar.verticalTabs" = {
          Value = true;
          Status = "default";
        };
      };
      ExtensionSettings =
        let
          moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
        in
        {
          "*".installation_mode = "allowed";
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = moz "bitwarden-password-manager";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
          "addon@darkreader.org" = {
            install_url = moz "darkreader";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          "idcac-pub@guus.ninja" = {
            install_url = moz "istilldontcareaboutcookies";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
          "uBlock0@raymondhill.net" = {
            install_url = moz "ublock-origin";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
            install_url = moz "vimium-ff";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };
        };
    };
  };
in
{
  options.homeSpec.apps.browsers.librewolf = {
    enable = lib.mkEnableOption "Enable librewolf browser module";
  };
  config = lib.mkIf cfg.enable {
    environment.etc."librewolf/policies/policies.json".text = builtins.toJSON policies;

    hjem.users.${config.hostSpec.userName} = {
      packages = [ pkgs.librewolf ];
      files.".librewolf/.keep".text = "";
      environment.sessionVariables = {
        LIBREWOLF_HOME = "$HOME/.librewolf";
      };
      systemd.services."librewolf-search-engines" = {
        description = "Seed LibreWolf custom search engines";
        wantedBy = [ "default.target" ];
        serviceConfig.Type = "oneshot";
        path = [ (pkgs.python3.withPackages (ps: [ ps.lz4 ])) ];
        script = ''
              PROFILE=$(find "$HOME/.librewolf" -maxdepth 1 -name "*.default" -type d | head -1)
              if [ -z "$PROFILE" ]; then
                exit 0
              fi

              python3 <<EOF
          import lz4.block, json, os

          profile = "$PROFILE"
          magic = b"mozLz40\0"
          data = json.dumps({
            "version": 13,
            "engines": [
              {
                "id": "google",
                "_name": "Google",
                "_isConfigEngine": True,
                "_metaData": { "hidden": True, "alias": "", "order": 1 }
              },
              {
                "id": "bing",
                "_name": "Bing",
                "_isConfigEngine": True,
                "_metaData": { "hidden": True, "alias": "", "order": 2 }
              },
              {
                "id": "ddg",
                "_name": "DuckDuckGo",
                "_isConfigEngine": True,
                "_metaData": { "order": 3 }
              },
              {
                "id": "perplexity",
                "_name": "Perplexity",
                "_isConfigEngine": True,
                "_metaData": { "hidden": True, "alias": "", "order": 4 }
              },
              {
                "id": "wikipedia",
                "_name": "Wikipedia (en)",
                "_isConfigEngine": True,
                "_metaData": { "hidden": True, "alias": "", "order": 5 }
              },
              {
                "id": "f81aaf52-3cd0-4c28-be6a-4ddd3b274531",
                "_name": "YouTube",
                "_loadPath": "[user]",
                "_metaData": { "alias": "!yt", "order": 6 },
                "_urls": [{ "params": [], "rels": [], "template": "https://www.youtube.com/results?search_query={searchTerms}" }],
                "_definedAliases": []
              },
              {
                "id": "nixos-pkgs",
                "_name": "NixOS Pkgs",
                "_loadPath": "[user]",
                "_metaData": { "alias": "!np", "order": 7 },
                "_urls": [{ "params": [], "rels": [], "template": "https://search.nixos.org/packages?query={searchTerms}&channel=unstable" }],
                "_definedAliases": []
              },
              {
                "id": "nixos-wiki",
                "_name": "NixOS Wiki",
                "_loadPath": "[user]",
                "_metaData": { "alias": "!nw", "order": 8 },
                "_urls": [{ "params": [], "rels": [], "template": "https://wiki.nixos.org/w/index.php?search={searchTerms}" }],
                "_definedAliases": []
              },
              {
                "id": "mynixos",
                "_name": "MyNixOS",
                "_loadPath": "[user]",
                "_metaData": { "alias": "!ns", "order": 9 },
                "_urls": [{ "params": [], "rels": [], "template": "https://mynixos.com/search?q={searchTerms}" }],
                "_definedAliases": []
              }
            ],
            "metaData": {
              "locale": "en-US",
              "region": "unknown",
              "channel": "default",
              "experiment": "",
              "distroID": "nixos",
              "useSavedOrder": True,
              "defaultEngineId": "ddg",
              "privateDefaultEngineId": "ddg"
            }
          }).encode("utf-8")

          compressed = lz4.block.compress(data)
          out = os.path.join(profile, "search.json.mozlz4")
          with open(out, "wb") as f:
            f.write(magic + compressed)
          EOF
        '';
      };
    };
  };
}
