{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.hostSpec = {
    userName = lib.mkOption {
      type = lib.types.str;
      description = "Username of the host";
    };
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "Hostname of the host";
    };
    hostType = lib.mkOption {
      type = lib.types.str;
      description = "System type of the host";
    };
    hostWM = lib.mkOption {
      type = lib.types.str;
      description = "Windowmanager of the host";
    };
    monitorName = lib.mkOption {
      type = lib.types.str;
      description = "Monitor name of the host";
      default = "";
    };
    mangoMonitor = lib.mkOption {
      type = lib.types.str;
      description = "Monitor setup for the host using Mango";
      default = "";
    };
    email = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Email of the user";
    };
    networking = lib.mkOption {
      default = { };
      type = lib.types.attrsOf lib.types.anything;
      description = "An attribute set of networking information";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Domain of the host";
    };
    userFullName = lib.mkOption {
      type = lib.types.str;
      description = "Full name of the user";
    };
    location = lib.mkOption {
      type = lib.types.str;
      description = "Location of the user";
    };
    handle = lib.mkOption {
      type = lib.types.str;
      description = "Handle of the user (eg: github user)";
    };
    home = lib.mkOption {
      type = lib.types.str;
      description = "Home directory of the user";
      default =
        let
          user = config.hostSpec.userName;
        in
        if pkgs.stdenv.isLinux then "/home/${user}" else "/Users/${user}";
    };
    persistFolder = lib.mkOption {
      type = lib.types.str;
      description = "Folder to persist data if impermenance is enabled";
      default = ""; # set in host config eg. /persist
    };
    isMinimal = lib.mkOption {
      type = lib.types.bool;
      description = "Used to indicate a minimal host";
      default = false;
    };
    isLaptop = lib.mkOption {
      type = lib.types.bool;
      description = "Used to indicate if host is a laptop";
      default = false;
    };
    isNvidia = lib.mkOption {
      type = lib.types.bool;
      description = "Used to indicate a nvidia host";
      default = false;
    };
    isGaming = lib.mkOption {
      type = lib.types.bool;
      description = "Used to indicate a gaming host";
      default = false;
    };
    isMultiDisk = lib.mkOption {
      type = lib.types.bool;
      description = "Used to indicate a multi disk host";
      default = false;
    };
    browser = lib.mkOption {
      type = lib.types.str;
      description = "Default browser to use";
    };
    colorTheme = lib.mkOption {
      type = lib.types.str;
      description = "Theme to use";
    };
  };
}
