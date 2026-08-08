{ inputs, ... }:
{
  flake.nixosModules.nixExtra =
    { config, lib, ... }:
    let
      githubToken =
        if config.sops.secrets ? "tokens/github" then
          "!include ${config.sops.secrets."tokens/github".path}"
        else
          "";
    in
    {
      nix =
        let
          flakeInputs = lib.filterAttrs (_: v: lib.isType "flake" v) inputs;
        in
        {
          # pin the registry to avoid downloading and evaling a new nixpkgs version every time
          registry = lib.mapAttrs (_: v: { flake = v; }) flakeInputs;

          # set the path for channels compat
          nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

          settings = {
            connect-timeout = 5;
            log-lines = 25;
            min-free = 128000000; # 128MB
            max-free = 1000000000; # 1GB

            auto-optimise-store = true;
            builders-use-substitutes = true;
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            flake-registry = "/etc/nix/registry.json";

            # for direnv GC roots
            keep-derivations = true;
            keep-outputs = true;

            trusted-users = [
              "root"
              "@wheel"
            ];

            accept-flake-config = false;
          };
          extraOptions = githubToken;
        };

    };
}
