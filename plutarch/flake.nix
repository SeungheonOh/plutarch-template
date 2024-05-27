{
  description = "plutarch-template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    haskell-nix.url = "github:input-output-hk/haskell.nix";
    iohk-nix.url = "github:input-output-hk/iohk-nix";
    iohk-nix.inputs.nixpkgs.follows = "haskell-nix/nixpkgs";

    CHaP.url = "github:input-output-hk/cardano-haskell-packages?ref=repo";
    CHaP.flake = false;

    MHaP.url = "github:mlabs-haskell/mlabs-haskell-packages?ref=gh-pages";
    MHaP.flake = false;

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = inputs@{ flake-parts, nixpkgs, haskell-nix, iohk-nix, CHaP, MHaP, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./nix/pre-commit.nix
      ];
      debug = true;
      systems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" "aarch64-linux" ];

      perSystem = { config, system, ... }:
        let
          pkgs =
            import haskell-nix.inputs.nixpkgs {
              inherit system;
              overlays = [
                haskell-nix.overlay
                iohk-nix.overlays.crypto
                iohk-nix.overlays.haskell-nix-crypto
              ];
              inherit (haskell-nix) config;
            };
          project = pkgs.haskell-nix.cabalProject' {
            src = ./.;
            compiler-nix-name = "ghc964";
            index-state = "2024-01-16T11:00:00Z";
            inputMap = {
              "https://input-output-hk.github.io/cardano-haskell-packages" = CHaP;
              "https://mlabs-haskell.github.io/mlabs-haskell-packages" = MHaP;
            };
            shell = {
              shellHook = config.pre-commit.installationScript;
              exactDeps = false;
              withHoogle = true;
              withHaddock = true;
              tools = {
                cabal = { };
              };
            };
          };
          flake = project.flake { };
        in
        {
          inherit (flake) devShells;
        };
    };
}
