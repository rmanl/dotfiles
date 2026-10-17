# https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt
{
  flake.nixosModules.browsersLibrewolf =
    { host, pkgs, ... }:
    let
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
              "Wikipedia"
            ];
            Add = [
              {
                Name = "YouTube";
                Alias = "!yt";
                URLTemplate = "https://www.youtube.com/results?search_query={searchTerms}";
              }
              {
                Name = "NixOS Pkgs";
                Alias = "!np";
                URLTemplate = "https://search.nixos.org/packages?query={searchTerms}&channel=unstable";
              }
              {
                Name = "NixOS Wiki";
                Alias = "!nw";
                URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
              }
              {
                Name = "MyNixOS";
                Alias = "!ns";
                URLTemplate = "https://mynixos.com/search?q={searchTerms}";
              }
            ];
          };
          Preferences = {
            "sidebar.verticalTabs" = {
              Value = true;
              Status = "default";
            };
            "media.peerconnection.ice.default_address_only" = {
              Value = true;
              Status = "locked";
            };
            "media.peerconnection.ice.no_host" = {
              Value = true;
              Status = "locked";
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
      environment.etc."librewolf/policies/policies.json".text = builtins.toJSON policies;

      hjem.users.${host.userName} = {
        packages = [ pkgs.librewolf ];
        files.".librewolf/.keep".text = "";
        environment.sessionVariables = {
          LIBREWOLF_HOME = "$HOME/.librewolf";
        };
      };
    };
}
