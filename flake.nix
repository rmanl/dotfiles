{
  description = "NixOS configuration";

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ (import ./modules/hosts/_base.nix { inputs = null; }).system ];
      imports = [ (inputs.import-tree ./modules) ];
    };

  inputs = {
    # ========= official nixos sources =========
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    hardware = {
      url = "github:nixos/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # ========= dendritic =========
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # ========= utilities =========
    #
    # home management
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # declarative partitioning and formatting
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # secrets management
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # pre-commit
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # secure boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # ========= personal repositories =========
    nix-secrets = {
      url = "git+ssh://git@github.com/rmanl/nix-secrets.git?ref=main&shallow=1";
      inputs = { };
    };
    monolisa = {
      url = "git+ssh://git@github.com/rmanl/monolisa.git?ref=main&shallow=1";
      flake = false;
    };
    themes = {
      url = "git+ssh://git@github.com/rmanl/frosty.nvim.git?ref=main&shallow=1";
      flake = false;
    };
  };
}
