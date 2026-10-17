{
  flake.nixosModules.zshRc =
    {
      host,
      config,
      inputs,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (host)
        colorTheme
        tuiFileManager
        userName
        ;
      aliasBlock = import ../_aliasBlock.nix { inherit lib; };
      c = config.colors;
    in
    {
      environment.shells = [ pkgs.zsh ];

      hjem.users.${userName} = {
        packages = with pkgs; [
          fzf
          zsh-autosuggestions
          zsh-syntax-highlighting
          zsh-nix-shell
        ];

        environment.sessionVariables = {
          ZDOTDIR = "/home/${userName}/.config/zsh";
        };

        files = {
          ".zshenv".text = ''
            . ${config.hjem.users.${userName}.environment.loadEnv}
          '';

          ".config/zsh/.zshrc".text = ''
            # --- options ---
            setopt AUTO_CD
            setopt HIST_EXPIRE_DUPS_FIRST
            setopt SHARE_HISTORY

            # --- history ---
            export HISTFILE="$ZDOTDIR/zsh_history"
            export HISTSIZE=10000
            export SAVEHIST=10000

            # --- completion ---
            autoload -Uz compinit
            compinit

            zstyle ':completion:*' completer _complete _ignored _approximate
            zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
            zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
            zstyle ':completion:*' menu select
            zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
            zstyle ':completion:*' verbose true
            zstyle ':completion:*' use-cache on
            zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
            _comp_options+=(globdots)

            # --- aliases ---
            ${aliasBlock}

            # --- autosuggestions / syntax highlighting ---
            source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
            source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
            ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
            typeset -A ZSH_HIGHLIGHT_STYLES
            ZSH_HIGHLIGHT_STYLES[alias]='fg=${c.base0E}'
            typeset -A ZSH_HIGHLIGHT_PATTERNS
            ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=${c.base00},bg=${c.base08}')

            # --- tool init ---
            source ${inputs.themes}/extra/fzf/${colorTheme}.zsh
            source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh
            eval "$(tirith init --shell zsh)"
            eval "$(zoxide init --cmd cd zsh)"
            eval "$(direnv hook zsh)"
            eval "$(starship init zsh)"
            source <(fzf --zsh)

            # search history based on what's typed in the prompt
            autoload -U history-search-end
            zle -N history-beginning-search-backward-end history-search-end
            zle -N history-beginning-search-forward-end history-search-end
            bindkey "^[OA" history-beginning-search-backward-end
            bindkey "^[OB" history-beginning-search-forward-end

            # change terminal title
            case $TERM in
              foot*|(dt|k|E)term)
                precmd () {
                  print -Pn "\e]0;[%~]\a"
                }
                preexec () { print -Pn "\e]0;[%~] ($1)\a" }
                ;;
              screen|screen-256color)
                precmd () {
                  print -Pn "\e]83;title \"$1\"\a"
                  print -Pn "\e]0;$TERM - (%L) [%~]\a"
                }
                preexec () {
                  print -Pn "\e]83;title \"$1\"\a"
                  print -Pn "\e]0;$TERM - (%L) [%~] ($1)\a"
                }
                ;;
            esac

            # M-t create dev template
            function dev() {
              source "$ZDOTDIR/dev-template.sh"
              zle reset-prompt > /dev/null 2>&1 || true
            }
            zle -N dev
            bindkey -M vicmd '\et' dev
            bindkey -M viins '\et' dev

            # M-n open felix in current directory
            function felix() {
              exec </dev/tty
              exec <&1
              ${tuiFileManager} "$PWD"
              zle reset-prompt > /dev/null 2>&1 || true
            }
            zle -N felix
            bindkey -M vicmd '\en' felix
            bindkey -M viins '\en' felix

            # M-p incognito mode
            function incognito() {
              exec </dev/tty
              exec <&1
              unset HISTFILE
              export PROMPT="%F{red}󰗹  %F{cyan}%2~"$'\n'"%F{green}› "
              zle reset-prompt > /dev/null 2>&1 || true
            }
            zle -N incognito
            bindkey -M vicmd '\ep' incognito
            bindkey -M viins '\ep' incognito
          '';
        };
      };
    };
}
