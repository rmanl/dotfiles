{
  flake.nixosModules.nvim =
    {
      host,
      pkgs,
      ...
    }:
    {
      hjem.users.${host.userName}.packages = with pkgs; [
        neovim
        nodejs
        cargo

        # language servers
        bash-language-server
        biome # + formatter/linter
        gopls
        lemminx
        lua-language-server
        marksman
        nil
        pyright
        sqls
        typescript-language-server
        vscode-langservers-extracted
        yaml-language-server

        # linters
        golangci-lint
        htmlhint
        luajitPackages.luacheck
        markdownlint-cli2
        statix
        yamllint

        # formatters
        deno
        goimports-reviser
        golines
        isort
        jq
        nixfmt
        prettierd
        ruff
        shellcheck # + linter
        shellharden
        shfmt
        sqlfluff # + linter
        stylua
        taplo
        xmlformat
        yamlfmt
      ];
    };
}
