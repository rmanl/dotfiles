{
  flake.nixosModules.scriptsArchive =
    { host, pkgs, ... }:
    let
      archivemenu = pkgs.writeShellScriptBin "archivemenu" ''
        set -euo pipefail

        dir="''${1:-$PWD}"

        notify_error() {
          notify-send -u normal -t 3000 -a "Archive" -i "script-error" "$1"
        }

        action=$(printf " Extract\n Compress" | fuzzel -d -l 2 -p "Archive: ") || exit 0
        [[ -z "$action" ]] && exit 0

        case "$action" in
        *Extract)
          file=$(find "$dir" -maxdepth 1 -type f \
            \( -iname '*.zip' -o -iname '*.tar' -o -iname '*.tar.gz' -o -iname '*.tgz' \
               -o -iname '*.tar.bz2' -o -iname '*.tbz2' -o -iname '*.tar.xz' -o -iname '*.txz' \
               -o -iname '*.7z' -o -iname '*.rar' \) -printf '%f\n' | sort |
            fuzzel -d -l 10 -p "Extract: ") || exit 0
          [[ -z "$file" ]] && exit 0

          archive="$dir/$file"
          [[ -e "$archive" ]] || archive="$file"
          [[ -e "$archive" ]] || {
            notify_error "No such file: $file"
            exit 1
          }

          filename=$(basename "$archive")
          target_dir=$(dirname "$archive")

          case "$filename" in
          *.tar.gz)
            base="''${filename%.tar.gz}"
            entries=$(tar -tf "$archive")
            extract() { tar -xf "$archive" -C "$1"; }
            ;;
          *.tgz)
            base="''${filename%.tgz}"
            entries=$(tar -tf "$archive")
            extract() { tar -xf "$archive" -C "$1"; }
            ;;
          *.tar.bz2)
            base="''${filename%.tar.bz2}"
            entries=$(tar -tf "$archive")
            extract() { tar -xf "$archive" -C "$1"; }
            ;;
          *.tbz2)
            base="''${filename%.tbz2}"
            entries=$(tar -tf "$archive")
            extract() { tar -xf "$archive" -C "$1"; }
            ;;
          *.tar.xz)
            base="''${filename%.tar.xz}"
            entries=$(tar -tf "$archive")
            extract() { tar -xf "$archive" -C "$1"; }
            ;;
          *.txz)
            base="''${filename%.txz}"
            entries=$(tar -tf "$archive")
            extract() { tar -xf "$archive" -C "$1"; }
            ;;
          *.tar)
            base="''${filename%.tar}"
            entries=$(tar -tf "$archive")
            extract() { tar -xf "$archive" -C "$1"; }
            ;;
          *.zip)
            base="''${filename%.zip}"
            entries=$(unzip -Z1 "$archive")
            extract() { unzip -o "$archive" -d "$1" >/dev/null; }
            ;;
          *.7z)
            base="''${filename%.7z}"
            entries=$(7z l -slt "$archive" | awk -F' = ' '/^Path/{print $2}' | tail -n +2)
            extract() { 7z x "$archive" -o"$1" -y >/dev/null; }
            ;;
          *.rar)
            base="''${filename%.rar}"
            entries=$(unrar lb "$archive")
            extract() { unrar x -o+ "$archive" "$1/" >/dev/null; }
            ;;
          *)
            notify_error "Unsupported archive format"
            exit 1
            ;;
          esac

          top=$(printf '%s\n' "$entries" | cut -d/ -f1 | sort -u)

          if [[ "$(printf '%s\n' "$top" | wc -l)" -eq 1 ]] && printf '%s\n' "$entries" | grep -q "^$top/"; then
            extract "$target_dir"
          else
            mkdir -p "$target_dir/$base"
            extract "$target_dir/$base"
          fi

          notify-send -u normal -t 2000 -a "Archive" "Extracted: $filename"
          ;;

        *Compress)
          selected=()
          done_marker="✅ Done - create archive"

          while true; do
            items=$(find "$dir" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort)
            for s in "''${selected[@]+"''${selected[@]}"}"; do
              items=$(printf '%s\n' "$items" | grep -vxF "$s")
            done

            if [[ "''${#selected[@]}" -gt 0 ]]; then
              items=$(printf '%s\n%s\n' "$done_marker" "$items")
            fi

            choice=$(printf '%s\n' "$items" |
              fuzzel -d -l 10 -p "Compress (''${#selected[@]} selected): ") || break
            [[ -z "$choice" ]] && break
            [[ "$choice" == "$done_marker" ]] && break

            path="$dir/$choice"
            [[ -e "$path" ]] || path="$choice"
            [[ -e "$path" ]] || {
              notify_error "No such file: $choice"
              continue
            }

            selected+=("$choice")
          done

          [[ "''${#selected[@]}" -eq 0 ]] && exit 0

          default_name=$(basename "''${selected[0]%/}")
          name=$(fuzzel -d --prompt-only="Archive name (default: $default_name): ") || exit 0
          [[ -z "$name" ]] && name="$default_name"

          (cd "$dir" && zip -r "$dir/$name.zip" "''${selected[@]}") >/dev/null
          notify-send -u normal -t 2000 -a "Archive" "Compressed: $name.zip (''${#selected[@]} item(s))"
          ;;
        esac
      '';
    in
    {
      hjem.users.${host.userName}.packages = with pkgs; [
        archivemenu
        zip
        unzip
        gnutar
        p7zip
        unrar
      ];
    };
}
