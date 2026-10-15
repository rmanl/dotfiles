{
  flake.nixosModules.hyprlandWmctl =
    { host, pkgs, ... }:
    let
      wmctl = pkgs.writeShellScriptBin "wmctl" ''
        set -euo pipefail

        socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

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
          "focused window") hyprctl activewindow ;;
          "tags") hyprctl workspaces ;;
          "outputs") hyprctl monitors ;;
          "keyboard layout") hyprctl devices ;;
          "keybind mode") hyprctl submap ;;
          "scale factor") hyprctl monitors ;;
          "all state") hyprctl --batch "activewindow;monitors;workspaces;devices;submap" ;;
          esac

          return 0
        }

        watch_menu() {
          choice=$(printf "%s\n" \
            "watch all events" \
            "watch focused window" |
            fuzzel -d -p "󰁯 watch: ") || return 0

          case "$choice" in
          "watch all events") socat -U - UNIX-CONNECT:"$socket" ;;
          "watch focused window") socat -U - UNIX-CONNECT:"$socket" | grep -E '^activewindow' ;;
          esac

          return 0
        }

        main_menu() {
          choice=$(printf "%s\n" \
            "snapshot (get state)" \
            "watch (live updates)" \
            "reload config" |
            fuzzel -d -p "󰒋 hyprland wmctl: ") || return 1

          case "$choice" in
          "snapshot (get state)") snapshot_menu return 0 ;;
          "watch (live updates)") watch_menu return 0 ;;
          "reload config") hyprctl reload ;;
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
      hjem.users.${host.userName} = {
        packages = [
          wmctl
          pkgs.socat
        ];
        files.".config/zsh/.zshrc".text = ''
          # reload hyprland config
          function reload() {
            hyprctl reload
          }

          # M-i wmctl
          function wmctl_run() {
            exec </dev/tty
            exec <&1
            wmctl
            zle reset-prompt > /dev/null 2>&1 || true
          }
          zle -N wmctl_run
          bindkey -M viins '\ei' wmctl_run
          bindkey -M vicmd '\ei' wmctl_run
        '';
      };
    };
}
