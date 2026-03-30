{
  description = "ppenguin's nix dev shells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    nixpkgs-unstable,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {system, ...}: let
        pkgs = import nixpkgs {
          config.allowUnfree = true;
          inherit system;
          overlays = [(import ./overlay.nix)];
        };
        unstable = import nixpkgs-unstable {
          inherit (pkgs) config;
          inherit system;
          overlays = [(import ./overlay.nix)];
        };
        inherit (pkgs) lib;

        getnixes = dir: prefix:
          with builtins;
            lib.attrNames
            (lib.filterAttrs (
              n: v:
                v
                == "regular"
                && (
                  lib.all (e: e)
                  (map (pfun: pfun (baseNameOf n))
                    [(lib.hasPrefix prefix) (lib.hasSuffix ".nix")])
                )
            ) (readDir dir));

        genshells = dir: prefix:
          lib.genAttrs
          (map (s: lib.removeSuffix ".nix" (lib.removePrefix prefix s))
            (getnixes dir prefix))
          (n: import (dir + "/${prefix}${n}.nix") {inherit pkgs;});

        genshells-unstable = dir: prefix:
          lib.mapAttrs'
          (n: v: lib.nameValuePair "${n}-unstable" v)
          (lib.genAttrs
            (map (s: lib.removeSuffix ".nix" (lib.removePrefix prefix s))
              (getnixes dir prefix))
            (n: import (dir + "/${prefix}${n}.nix") {pkgs = unstable;}));
      in {
        # devshells generated from ./dev plus extras
        devShells =
          (genshells ./dev "devshell-")
          // (genshells-unstable ./dev "devshell-")
          // {
            test = import ./dev/test.nix {inherit pkgs;};
            default = import ./dev/test.nix {inherit pkgs;}; # flake-parts expects a `default` — adjust as needed
            dev-fhs-simple = import ./dev/fhs-simple.nix {inherit pkgs;};
          };

        # expose getnixes as a package-level passthru via legacyPackages
        legacyPackages.getnixes = getnixes;
      };
    };
}
