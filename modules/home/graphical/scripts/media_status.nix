{
  flake.nixosModules.scriptsMediaStatus =
    {
      host,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (host) mediaPlayer spotify;
      media_status = pkgs.writeShellScriptBin "media_status" ''
        PLAYERS=("${mediaPlayer}" "${spotify}") # playerctl -l
        FORMAT="{{ title }} ({{ artist }})"

        get_player_status() {
          local player=$1
          playerctl --player="$player" status 2>/dev/null
        }

        get_player_metadata() {
          local player=$1
          playerctl --player="$player" metadata --format "$FORMAT"
        }

        if [ "$1" = "--scroll" ]; then
          ${lib.getExe pkgs.zscroll} -l 20 \
            --delay 0.1 \
            --scroll-padding " " \
            --match-command "media_status --status" \
            --match-text "Playing" "--scroll 1" \
            --match-text "Paused" "--scroll 0" \
            --update-check true "media_status" &
          wait
          exit 0
        fi

        PLAYER_STATUS=""
        PLAYER=""

        for player in "''${PLAYERS[@]}"; do
          PLAYER_STATUS=$(get_player_status "$player")
          if [ $? -eq 0 ]; then
            PLAYER=$player
            break
          fi
        done

        if [ -z "$PLAYER" ]; then
          PLAYER_STATUS="No player is running"
        fi

        case "$1" in
          --play-pause|--previous|--next)
            if [ -n "$PLAYER" ]; then
              playerctl --player="$PLAYER" "''${1#--}"
            else
              playerctl "''${1#--}"
            fi
            exit 0
            ;;
        esac

        if [ "$1" = "--status" ]; then
          echo "$PLAYER_STATUS"
        else
          case "$PLAYER_STATUS" in
            "Stopped")
              echo "No music is playing"
              ;;
            "Paused")
              get_player_metadata "$PLAYER"
              ;;
            "No player is running")
              echo ""
              ;;
            *)
              get_player_metadata "$PLAYER"
              ;;
          esac
        fi
      '';
    in
    {
      hjem.users.${host.userName}.packages = [ media_status ];
    };
}
