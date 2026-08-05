{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.desktop.scripts.media_status;
  media_status = pkgs.writeShellScriptBin "media_status" ''
    PLAYERS=("mpv" "spotify" "spotify_player") # playerctl -l
    FORMAT="{{ title }} ({{ artist }})"

    get_player_status() {
      local player=$1
      playerctl --player="$player" status 2>/dev/null
    }

    get_player_metadata() {
      local player=$1
      playerctl --player="$player" metadata --format "$FORMAT"
    }

    # check if a player is running
    PLAYER_STATUS=""
    PLAYER=""

    for player in "''${PLAYERS[@]}"; do
      PLAYER_STATUS=$(get_player_status "$player")
      if [ $? -eq 0 ]; then
        PLAYER=$player
        break
      fi
    done

    # if no player is running
    if [ -z "$PLAYER" ]; then
      PLAYER_STATUS="No player is running"
    fi

    # output based on current player status
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
  options.homeSpec.desktop.scripts.media_status = {
    enable = lib.mkEnableOption "Enable media_status script";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = [ media_status ];
  };
}
