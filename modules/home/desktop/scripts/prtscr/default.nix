{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.desktop.scripts.prtscr;
  prtscr = pkgs.writeShellScriptBin "prtscr" ''
    set -euo pipefail

    dir="$HOME/data/stuff/pics/screenshots"
    location="$dir/$(date +'screenshot_%y%m%d_%Hh%Mm%Ss.png')"

    notify_error() {
      notify-send -u normal -t 2000 -a "Screenshot" -i "script-error" "$1"
    }

    notify_success() {
      notify-send -u normal -t 2000 -a "Screenshot" -i "$location" "$1"
    }

    full() {
      grim "$location"
      notify_success "Saved: $location"
    }

    area() {
      geometry="$(slurp)" || exit 0
      [ "$geometry" = "" ] && exit 0

      grim -g "$geometry" "$location"
      notify_success "Saved: $location"
    }

    annotate() {
      # list screenshots (newest first)
      files=$(ls -t "$dir" 2>/dev/null || true)

      [[ -z "$files" ]] && {
        notify_error "No screenshots found"
        return 0
      }

      count=$(printf '%s\n' "$files" | wc -l)

      selected=$(printf '%s\n' "$files" |
        fuzzel -d -l "$count" -p "󰲶 Annotate: ") || selected=""

      [[ -z "$selected" ]] && return 0

      satty -f "$dir/$selected"
      exit 0
    }

    annotate_new() {
      choice=$(printf " Full screen\n Area selection" | fuzzel -d -l 2 -p "󰹑 Capture mode: ") || return 0
      [[ -z "$choice" ]] && return 0

      case "$choice" in
        *Full*)
          grim "$location"
          ;;
        *Area*)
          geometry="$(slurp)" || return 0
          [ -z "$geometry" ] && return 0
          grim -g "$geometry" "$location"
          ;;
      esac

      notify_success "Saved: $location"
      satty -f "$location"
      exit 0
    }

    menu() {
      while true; do
        choice=$(printf " Full screen\n Area selection\n󰲶 Annotate screenshot\n󰷬 Annotate new screenshot" |
          fuzzel -d -l 4 -p "󰹑 Screenshot: ") || choice=""

        [[ -z "$choice" ]] && exit 0

        case "$choice" in
        *Full*)
          full
          exit 0
          ;;
        *Area*)
          area
          exit 0
          ;;
        *new\ screenshot*)
          annotate_new
          ;;
        *Annotate*)
          annotate
          ;;
        esac
      done
    }

    menu
  '';
in
{
  options.homeSpec.desktop.scripts.prtscr = {
    enable = lib.mkEnableOption "Enable prtscr script";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = with pkgs; [
      prtscr
      grim
      slurp
      satty
    ];
  };
}
