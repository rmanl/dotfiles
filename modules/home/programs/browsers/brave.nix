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
        DefaultBrowserSettingEnabled = false;
        DefaultSearchProviderEnabled = true;
        DefaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
        DefaultSearchProviderSuggestURL = "https://duckduckgo.com/ac/?q={searchTerms}&type=list";
        SiteSearchSettings = [
          {
            name = "YouTube";
            shortcut = "!yt";
            url = "https://www.youtube.com/results?search_query={searchTerms}";
          }
          {
            name = "MyNixOS";
            shortcut = "!ns";
            url = "https://mynixos.com/search?q={searchTerms}";
          }
          {
            name = "NixOS Pkgs";
            shortcut = "!np";
            url = "https://search.nixos.org/packages?type=packages&query={searchTerms}";
          }
          {
            name = "NixOS Wiki";
            shortcut = "!nw";
            url = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
          }
        ];
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
      };
    };
}
