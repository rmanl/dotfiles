{
  flake.nixosModules.browsersBrave =
    { host, pkgs, ... }:
    let
      policies = {
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        BraveAIChatEnabled = false;
        BraveNewsDisabled = true;
        BraveP3AEnabled = false;
        BravePlaylistEnabled = false;
        BraveRewardsDisabled = true;
        BraveSpeedreaderEnabled = false;
        BraveStatsPingEnabled = false;
        BraveTalkDisabled = true;
        BraveVPNDisabled = true;
        BraveWalletDisabled = true;
        BraveWaybackMachineEnabled = false;
        BraveWebDiscoveryEnabled = false;
        DefaultSearchProviderEnabled = true;
        DefaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
        DefaultSearchProviderSuggestURL = "https://duckduckgo.com/ac/?q={searchTerms}&type=list";
        EncryptedMediaExtensions = {
          Enabled = true;
          Locked = false;
        };
        ExtensionSettings = {
          "nngceckbapebfimnlniiiahkandclblb" = {
            installation_mode = "force_installed";
            update_url = "https://clients2.google.com/service/update2/crx";
          }; # bitwarden
          "eimadpbcbfnmbkopoojfekhnkhdbieeh" = {
            installation_mode = "force_installed";
            update_url = "https://clients2.google.com/service/update2/crx";
          }; # dark reader
          "dbepggeogbaibhgnhhndojpepiihcmeb" = {
            installation_mode = "force_installed";
            update_url = "https://clients2.google.com/service/update2/crx";
          }; # vimium
          "annfbnbieaamhaimclajlajpijgkdblo" = {
            installation_mode = "force_installed";
            update_url = "https://clients2.google.com/service/update2/crx";
          }; # dark theme
        };
        DnsOverHttpsMode = "secure";
        DnsOverHttpsTemplates = "https://dns.adguard-dns.com/dns-query";
        PasswordManagerEnabled = false;
        NoDefaultBookmarks = true;
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
        SyncDisabled = false;
        TorDisabled = true;
        TranslateEnabled = false;
        WebRtcIPHandling = "default_public_interface_only";
      };
    in
    {
      environment.etc."brave/policies/managed/policies.json".text = builtins.toJSON policies;

      hjem.users.${host.userName} = {
        packages = [ pkgs.brave ];
        systemd.services."brave-search-engines" = {
          description = "Seed Brave custom search engine shortcuts";
          wantedBy = [ "default.target" ];
          serviceConfig.Type = "oneshot";
          path = [ pkgs.sqlite ];
          script = ''
            DB="$HOME/.config/BraveSoftware/Brave-Browser/Default/Web Data"

            if [ ! -f "$DB" ]; then
              exit 0
            fi

            sqlite3 "$DB" <<SQL
              INSERT OR IGNORE INTO keywords
                (short_name, keyword, url, favicon_url, safe_for_autoreplace, date_created)
              VALUES
                ('YouTube',    '!yt',  'https://www.youtube.com/results?search_query={searchTerms}',                           'https://youtube.com/favicon.ico', 0, strftime('%s','now')),
                ('MyNixOS',    '!ns',  'https://mynixos.com/search?q={searchTerms}',                                           'https://mynixos.com/favicon.ico', 0, strftime('%s','now')),
                ('NixOS Pkgs', '!np',  'https://search.nixos.org/packages?type=packages&query={searchTerms}',                  'https://search.nixos.org/favicon.ico', 0, strftime('%s','now')),
                ('NixOS Wiki', '!nw',  'https://wiki.nixos.org/w/index.php?search={searchTerms}',                              'https://wiki.nixos.org/favicon.ico', 0, strftime('%s','now'));
            SQL
          '';
        };
      };
    };
}
