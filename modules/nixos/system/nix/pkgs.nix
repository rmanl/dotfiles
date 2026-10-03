{
  flake.nixosModules.nixPkgs =
    {
      lib,
      pkgs,
      inputs,
      ...
    }:
    let
      allowedUnfree = [
        "claude-code"
        "spotify"
        "steam"
        "unrar"
      ];
      isCudaEula =
        pkg:
        let
          licenses = lib.toList (pkg.meta.license or [ ]);
        in
        builtins.any (l: (l.shortName or "") == "CUDA EULA") licenses;
      isUnfree =
        pkg:
        let
          name = pkg.pname or pkg.name;
        in
        builtins.elem name allowedUnfree || lib.hasPrefix "nvidia" name || isCudaEula pkg;
    in
    {
      nixpkgs.config.allowUnfreePredicate = isUnfree;

      _module.args.pkgs-unstable = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfreePredicate = isUnfree;
      };
    };
}
