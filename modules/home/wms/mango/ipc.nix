{
  flake.nixosModules.mangoIpc =
    { host, pkgs, ... }:
    let
      ipc = pkgs.writeShellScriptBin "ipc" ''
        set -euo pipefail

        snapshot_menu() {
          choice=$(printf "%s\n" \
            "focused window" \
            "tags" \
            "outputs" \
            "keyboard layout" \
            "keybind mode" \
            "scale factor" \
            "all state" |
            fuzzel -d -p "󰒋 snapshot: ") || return 0

          case "$choice" in
          "focused window") mmsg -g -c ;;
          "tags") mmsg -g -t ;;
          "outputs") mmsg -o ;;
          "keyboard layout") mmsg -g -k ;;
          "keybind mode") mmsg -g -b ;;
          "scale factor") mmsg -g -a ;;
          "all state") mmsg -g ;;
          esac

          return 0
        }

        watch_menu() {
          choice=$(printf "%s\n" \
            "watch all events" \
            "watch focused window" |
            fuzzel -d -p "󰁯 watch: ") || return 0

          case "$choice" in
          "watch all events") mmsg -w ;;
          "watch focused window") mmsg -w -c ;;
          esac

          return 0
        }

        main_menu() {
          choice=$(printf "%s\n" \
            "snapshot (get state)" \
            "watch (live updates)" |
            fuzzel -d -p "󰒋 mango ipc: ") || return 1

          case "$choice" in
          "snapshot (get state)") snapshot_menu return 0 ;;
          "watch (live updates)") watch_menu return 0 ;;
          esac
        }

        main() {
          while true; do
            main_menu || break
          done
        }

        main
      '';
    in
    {
      hjem.users.${host.userName}.packages = [ ipc ];
    };
}
