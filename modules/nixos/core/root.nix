{
  flake.nixosModules.coreRoot =
    { host, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        bat
        bat-extras.batdiff
        eza
        fd
        ripgrep
        wget2
      ];

      programs.zsh.shellAliases = {
        cat = "bat";
        diff = "batdiff";

        l = "eza -l --group-directories-first";
        la = "eza -la --group-directories-first";
        lt = "eza -lah --tree";
        tree = "eza --tree --icons --tree";

        btar = "tar -cvf";
        untar = "tar -xf";
        wget = "wget2";
        mkdir = "mkdir -pv";

        mv = "mv -i";
        cp = "cp -i";
        rm = "rm -i";

        v = "vim";

        dots = "cd /home/${host.userName}/.config/frosty";
      };

      programs.zsh.promptInit = ''
        if [[ $EUID -eq 0 ]]; then
          PROMPT="%F{red}root %F{cyan}%~%f"$'\n'"%F{red}# %f"
        fi
      '';
    };
}
