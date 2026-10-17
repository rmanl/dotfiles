{
  flake.nixosModules.scriptsCodex =
    {
      host,
      pkgs,
      lib,
      config,
      ...
    }:
    let
      aliases = import ../../shell/_aliases.nix host;
      aliasPairs = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: cmd: "${name}\t${cmd}") aliases);

      themeColors = lib.filterAttrs (
        name: _: builtins.match "base0[0-9A-F]" name != null
      ) config.colors.withHashtag;
      themePairs = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: hex: "${name}:${hex}") themeColors
      );

      codex = pkgs.writeShellScriptBin "codex" ''
        set -euo pipefail

        wm_config_dir="$HOME/.config/$XDG_CURRENT_DESKTOP"
        swatch_dir=$(mktemp -d)
        trap 'rm -rf "$swatch_dir"' EXIT

        parse_generic() {
          local files=()
          [[ -f "$wm_config_dir/binds.conf" ]] && files+=("$wm_config_dir/binds.conf")
          [[ -f "$wm_config_dir/scratchpads.conf" ]] && files+=("$wm_config_dir/scratchpads.conf")

          if [[ ''${#files[@]} -eq 0 ]]; then
            return 1
          fi

          awk '
            /^# [a-z]+$/ {
              cat = substr($0, 3)
              next
            }
            /^(bind|mousebind|axisbind|gesturebind)=/ {
              line = $0
              hashPos = 0
              for (i = length(line); i >= 1; i--) {
                if (substr(line,i,1) == "#") { hashPos = i; break }
              }
              if (hashPos == 0) next
              desc = substr(line, hashPos+1)
              gsub(/^[ \t]+|[ \t]+$/, "", desc)
              def = substr(line, 1, hashPos-1)
              gsub(/[ \t]+$/, "", def)

              eq = index(def, "=")
              type = substr(def, 1, eq-1)
              rest = substr(def, eq+1)
              split(rest, f, ",")

              if (type == "gesturebind") {
                combo = f[3] "-finger " f[2] " swipe"
              } else {
                mod = f[1]; key = f[2]
                combo = (mod == "none") ? key : mod "+" key
              }

              catCap = toupper(substr(cat,1,1)) substr(cat,2)
              descCap = toupper(substr(desc,1,1)) substr(desc,2)

              printf "%s\t%s\t%s\n", catCap, combo, descCap
            }
          ' "''${files[@]}"
        }

        show_wm_binds() {
          local sel
          sel=$(
            # escape hatch: WMs with a native bind-introspection API should get
            # their own branch here instead of relying on parse_generic — e.g.
            # Hyprland's `hyprctl bind -j`, which has a real description field
            # and can't drift from what's actually bound, unlike text scraping.
            case "$XDG_CURRENT_DESKTOP" in
              *)
                if ! parse_generic; then
                  echo "codex: no binds.conf found for '$XDG_CURRENT_DESKTOP'" >&2
                  exit 1
                fi
                ;;
            esac \
              | awk -F'\t' '{ printf "%-23s %-45s [%s]\n", $2, $3, $1 }' \
              | fuzzel -d -l 30 -w 75 -p "⌨ $wm_label: "
          ) || sel=""
          [[ -z "$sel" ]] && return 0
          return 2
        }

        show_shell() {
          local sel entries
          entries=$(
            printf '%s\n' \
              "M-t	Open dev template	Shell bind" \
              "M-n	Open file manager (cwd)	Shell bind" \
              "M-p	Toggle incognito mode	Shell bind"
            # per-WM shell binds that only apply under that WM (e.g. a future
            # hyprland branch here for a hyprctl-backed bind)
            case "$XDG_CURRENT_DESKTOP" in
              mango) printf '%s\n' "M-i	Toggle mango ipc	Shell bind" ;;
            esac
            while IFS=$'\t' read -r name cmd; do
              skip=0
              for var in $(grep -oE '\$[A-Za-z_][A-Za-z0-9_]*' <<< "$cmd" | tr -d '$'); do
                [[ -z "''${!var:-}" ]] && { skip=1; break; }
              done
              [[ $skip -eq 1 ]] && continue
              expanded="''${cmd@P}"
              expanded="''${expanded/$HOME/\~}"
              printf '%s\t%s\tAlias\n' "$name" "$expanded"
            done < <(printf '%s\n' '${aliasPairs}')
          )

          # size columns and window width to the actual data instead of hardcoded
          # guesses, so longer future entries don't overflow or misalign
          local w1 w2 w3
          read -r w1 w2 w3 <<< "$(awk -F'\t' '
            { if (length($1)>w1) w1=length($1); if (length($2)>w2) w2=length($2); if (length($3)>w3) w3=length($3) }
            END { print w1, w2, w3 }
          ' <<< "$entries")"
          w1=$(( w1 + 2 ))
          w2=$(( w2 + 2 ))

          sel=$(
            printf '%s\n' "$entries" \
              | awk -F'\t' -v w1="$w1" -v w2="$w2" '{ printf "%-" w1 "s %-" w2 "s [%s]\n", $1, $2, $3 }' \
              | fuzzel -d -l 30 -w "$(( w1 + w2 + w3 + 7 ))" -p "⌨ Shell binds: "
          ) || sel=""
          [[ -z "$sel" ]] && return 0
          return 2
        }

        show_theme() {
          local sel
          sel=$(
            while IFS=: read -r key hex; do
              swatch="$swatch_dir/$key.png"
              ${pkgs.imagemagick}/bin/magick -size 32x32 "xc:$hex" "$swatch"
              printf '%s  %s\0icon\x1f%s\n' "$key" "$hex" "$swatch"
            done < <(printf '%s\n' '${themePairs}') \
              | fuzzel -d -l 20 -w 40 -p "🎨 Theme (${host.colorTheme}): "
          ) || sel=""
          [[ -z "$sel" ]] && return 0
          return 2
        }

        show_notifications() {
          local sel history count copy
          history=$(makoctl history -j)
          count=$(${pkgs.jq}/bin/jq 'length' <<< "$history")

          if [[ "$count" -eq 0 ]]; then
            notify-send -u normal -t 2000 "Notification history" "No notifications in history"
            return 0
          fi

          sel=$(${pkgs.jq}/bin/jq -r '.[] | (.body // .summary)' <<< "$history" \
            | fuzzel -d -l "$count" -p "History: ") || sel=""
          [[ -z "$sel" ]] && return 0

          copy=$(printf '%s' "$sel" | sed -n "s/.*'\\(.*\\)'.*/\\1/p")
          [[ -z "$copy" ]] && copy="$sel"

          printf '%s' "$copy" | wl-copy
          return 2
        }

        wm_label="$(echo "$XDG_CURRENT_DESKTOP" | awk '{print toupper(substr($0,1,1)) substr($0,2)}') binds"

        while true; do
          choice=$(printf '%s\nShell binds\nTheme\nNotifications\n' "$wm_label" | fuzzel -d -p "📖 Codex: ") || choice=""
          [[ -z "$choice" ]] && exit 0

          rc=0
          case "$choice" in
            "$wm_label") show_wm_binds || rc=$? ;;
            "Shell binds") show_shell || rc=$? ;;
            "Theme") show_theme || rc=$? ;;
            "Notifications") show_notifications || rc=$? ;;
          esac
          [[ $rc -eq 2 ]] && exit 0
        done
      '';
    in
    {
      hjem.users.${host.userName}.packages = [ codex ];
    };
}
