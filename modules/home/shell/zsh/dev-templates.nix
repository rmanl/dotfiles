{
  flake.nixosModules.zshDevTemplates =
    { host, ... }:
    {
      hjem.users.${host.userName}.files.".config/zsh/dev-template.sh" = {
        executable = true;
        text = ''
          : "''${XDG_PROJECTS_DIR:?XDG_PROJECTS_DIR not set}"

          FLAKE_REF="github:the-nix-way/dev-templates"

          # ---- notify helpers ----
          notify_error() {
            local msg="$1"
            notify-send -u normal -t 3000 -a "Dev Template" -i "script-error" "$msg"
          }

          notify_success() {
            local msg="$1"
            notify-send -u normal -t 3000 -a "Dev Template" -i "emblem-checked" "$msg"
          }

          # ---- create new project ----
          create_project() {
            local prompt_text=" Project name: "
            local env_options=$'󰟓 go\n node\n󰌠 python'
            local env_count
            env_count=$(printf '%s\n' "$env_options" | wc -l | tr -d ' ')

            while true; do
              # Select environment (strip icon for folder name)
              local env_line env_tmp
              env_line=$(printf '%s\n' "$env_options" |
                fuzzel -d -l "$env_count" -p " Environment: ") || env_line=""
              env_tmp=$(echo "$env_line" | awk '{print $2}') || env_tmp=""
              [[ -z "$env_tmp" ]] && return 0

              # Project name
              local pj_dir
              pj_dir=$(fuzzel -d -l 0 -p "$prompt_text") || pj_dir=""
              [[ -z "$pj_dir" ]] && continue

              local target_dir="$XDG_PROJECTS_DIR/$env_tmp/$pj_dir"
              mkdir -p "$XDG_PROJECTS_DIR/$env_tmp" &>/dev/null

              if [[ -e "$target_dir" ]]; then
                notify_error "Project already exists: $target_dir"
                continue
              fi

              if ! nix flake new -t "$FLAKE_REF#$env_tmp" "$target_dir"; then
                notify_error "Flake creation failed"
                continue
              fi

              mkdir -p "$target_dir/code" &>/dev/null

              if [[ "$env_tmp" == "go" ]]; then
                export GOPATH="$XDG_PROJECTS_DIR/go/.workspaces/''${pj_dir}"
                mkdir -p "$GOPATH" &>/dev/null
              fi

              cd "$target_dir" || return 1
              direnv allow &>/dev/null
              cd "$target_dir/code" || return 1

              notify_success "Created $target_dir ($env_tmp)"
              return 2
            done
          }

          # ---- open project ----
          open_project() {
            while true; do
              local projects_str
              projects_str=$(find "$XDG_PROJECTS_DIR" -mindepth 2 -maxdepth 2 -type d \
                ! -name ".workspaces" 2>/dev/null | sort)

              if [[ -z "$projects_str" ]]; then
                notify_error "No projects found. Create a new project..."
                create_project
                [[ $? -eq 2 ]] && return 2
                return 0
              fi

              local project_count
              project_count=$(printf '%s\n' "$projects_str" | wc -l)

              local selected
              selected=$(printf '%s\n' "$projects_str" |
                fuzzel -d -l "$project_count" -p " Projects: ") || selected=""
              [[ -z "$selected" ]] && return 0

              cd "$selected/code" 2>/dev/null || {
                notify_error "Missing code directory"
                return 0
              }

              notify_success "Opened $selected"
              return 2
            done
          }

          # ---- main menu ----
          dev_template() {
            while true; do
              local choice
              choice=$(printf "Open project\nCreate new project" |
                fuzzel -d -l 2 -p " Actions: ") || choice=""
              [[ -z "$choice" ]] && return 0

              case "$choice" in
              "Open project")
                open_project
                [[ $? -eq 2 ]] && return 0
                ;;
              "Create new project")
                create_project
                [[ $? -eq 2 ]] && return 0
                ;;
              esac
            done
          }

          dev_template &>/dev/null
        '';
      };
    };
}
