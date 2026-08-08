{
  flake.nixosModules.claude =
    {
      host,
      pkgs,
      config,
      inputs,
      ...
    }:
    let
      inherit (host) userName colorTheme;
      colors = config.colors;
    in
    {
      hjem.users.${userName} = {
        packages = [ pkgs.claude-code ];
        files = {
          ".claude/settings.json" = {
            generator = (pkgs.formats.json { }).generate "settings.json";
            value = {
              theme = "custom:${colorTheme}";
              statusLine = {
                type = "command";
                command = "~/.claude/statusline.sh";
              };
            };
          };
          ".claude/statusline.sh" = {
            executable = true;
            text = with colors; ''
              #!/usr/bin/env bash
              input=$(cat)

              chip_bg="${base03}"
              dim="${base03}"
              text="${base06}"
              alt="${base00}"

              hex2rgb() { printf '%d;%d;%d' "0x''${1:0:2}" "0x''${1:2:2}" "0x''${1:4:2}"; }
              fg() { printf '\033[38;2;%sm' "$(hex2rgb "$1")"; }
              bg() { printf '\033[48;2;%sm' "$(hex2rgb "$1")"; }
              reset=$'\033[0m'

              chip() { printf '%s%s %s %s' "$(bg "$chip_bg")" "$(fg "$alt")" "$1" "$reset"; }
              strip_ansi() { printf '%s' "$1" | sed -E 's/\x1b\[[0-9;]*m//g'; }

              model=$(echo "$input" | jq -r '.model.display_name')
              cwd=$(echo "$input" | jq -r '.workspace.current_dir')
              used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
              lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
              lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

              dir_name=$(basename "$cwd")

              branch=""
              if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
              	branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
              fi

              left="$(chip "$model")"

              [ -n "$branch" ] && left="''${left} $(fg "$text") ''${branch}''${reset}"

              if [ "$lines_added" != "0" ] || [ "$lines_removed" != "0" ]; then
              	left="''${left} $(fg "$dim")+''${lines_added} -''${lines_removed}''${reset}"
              fi

              left="''${left}  $(fg "$dim")''${dir_name}''${reset}"

              ctx_int=''${used_pct%.*}
              right="$(chip "''${ctx_int}% ctx")"

              cols="''${COLUMNS:-80}"
              left_plain=$(strip_ansi "$left")
              right_plain=$(strip_ansi "$right")
              pad=$((cols - ''${#left_plain} - ''${#right_plain}))
              [ "$pad" -lt 1 ] && pad=1

              printf "%b%*s%b\n" "$left" "$pad" "" "$right"
            '';
          };
          ".claude/themes/${colorTheme}.json".source = "${inputs.themes}/extra/claude/${colorTheme}.json";
          ".claude/CLAUDE.md".text = ''
            # Global Claude Preferences

            ## Memory

            Save memory proactively during sessions when significant work is done.
            User will signal before closing the terminal — use that moment for a final memory save.

            ## Communication

            - Keep responses short and concise
            - No emojis unless explicitly asked
            - No trailing summaries after completing a task
            - For exploratory questions, give a recommendation and the main tradeoff in 2-3 sentences

            ## Making changes

            - Discuss and agree on approach before implementing anything non-trivial
            - For small multi-file changes: list all changes upfront, wait for one confirmation, then execute
            - For large or structural changes: show and confirm one change at a time
            - Stay focused on what was asked — do not clean up surrounding code unless asked

            ## Git commits

            - Never add a `Co-Authored-By: Claude` trailer to commits
            - Before committing, show the exact commit message and diff --stat, then wait for explicit approval

            ## Code style

            - No comments by default; if a comment seems genuinely necessary, flag it with a reason and ask
            - Prefer editing existing files over creating new ones
            - Do not add error handling, abstractions, or cleanup beyond what was asked — flag with a reason if you think it is warranted
            - Don't hand-format code. Check `~/.config/nvim` for a configured formatter (e.g. conform.nvim) and prefer running that; otherwise use the project's own formatter/pre-commit/lint setup (e.g. `pre-commit run --all-files`, `make fmt`). Don't manually match indentation/style — let the tool normalize it.
          '';
        };
      };
    };
}
