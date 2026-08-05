{
  description = "NixOS configuration";

  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      nixpkgs.config.allowUnfree = true;
    };

  inputs = {
    # ========= official nixos sources =========
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";
    # ========= blueprint framework =========
    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
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
    lanzaboote.url = "github:nix-community/lanzaboote";
    # spotify theming
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    # ========= personal repositories =========
    nix-secrets = {
      url = "git+ssh://git@github.com/rmanl/nix-secrets.git?ref=main&shallow=1";
      inputs = { };
    };
    monolisa = {
      url = "git+ssh://git@github.com/rmanl/monolisa.git?ref=main&shallow=1";
      flake = false;
    };
  };

}
