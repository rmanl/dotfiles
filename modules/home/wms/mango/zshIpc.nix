{
  flake.nixosModules.mangoZshIpc =
    { host, ... }:
    {
      hjem.users.${host.userName}.files.".config/zsh/.zshrc".text = ''
        # M-i mango ipc
        function ipc_run() {
          exec </dev/tty
          exec <&1
          ipc
          zle reset-prompt > /dev/null 2>&1 || true
        }
        zle -N ipc_run
        bindkey -M viins '\ei' ipc_run
        bindkey -M vicmd '\ei' ipc_run
      '';
    };
}
