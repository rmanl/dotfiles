{
  config,
  lib,
  perSystem,
  pkgs,
  ...
}:
let
  cfg = config.homeSpec.apps.nvim;
in
{
  options.homeSpec.apps.nvim = {
    enable = lib.mkEnableOption "Enable nvim module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.packages = [
      perSystem.nixpkgs-unstable.neovim
    ]
    ++ (with pkgs; [
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
      emacsPackages.deno-fmt
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
    ]);
  };
}
