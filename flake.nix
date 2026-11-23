{
  description = "ppenguin's nix dev shells";

  inputs = {
    # same as nixos-den (codeberg.org/ppenguin/nixos-den)
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
    jupyter = {
      url = "github:kirelagin/jupyter.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    nixpkgs-unstable,
    jupyter,
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
        config.allowUnfree = true;
        pkgs = import nixpkgs {
          inherit system config;
          overlays = [(import ./overlay.nix)];
        };
        # NOTE: not `pkgs.config` (normalized; newer opts e.g. `rewriteURL` break older nixpkgs)
        unstable = import nixpkgs-unstable {
          inherit config;
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

        plots = import ./run/jupyter {
          inherit pkgs;
          jupyterLib = jupyter.lib;
        };
        # lab entrypoints only (no server `python`) first on PATH, then kernel libs (python, panel, marimo, ...)
        labShell = lab:
          pkgs.mkShell {
            packages = [
              (pkgs.runCommand "${lab.name}-bin" {} ''
                mkdir -p $out/bin
                ln -s ${lab}/bin/jupyter ${lab}/bin/jupyter-* ${lab}/bin/jupytext $out/bin/
              '')
              lab.shellPython
            ];
          };
      in {
        # jupyter labs + plotting servers (`nix run .#jupyter-plots` etc), see run/jupyter/README.md
        packages = plots;

        # devshells generated from ./dev plus extras
        devShells =
          (genshells ./dev "devshell-")
          // (genshells-unstable ./dev "devshell-")
          // {
            test = import ./dev/test.nix {inherit pkgs;};
            default = import ./dev/test.nix {inherit pkgs;}; # flake-parts expects a `default` — adjust as needed
            dev-fhs-simple = import ./dev/fhs-simple.nix {inherit pkgs;};
            plots = labShell plots.jupyter-plots;
          }
          # per lab: jupyter-lab, jupytext (w/ pairing cfg), kernel libs on PATH
          # -> `nix develop .#jupyter-plots`, run `jupyter-lab` + `claude` inside, both see the same libs
          // lib.mapAttrs (_: labShell)
          (lib.filterAttrs (n: _: lib.hasPrefix "jupyter-" n) plots);

        # expose getnixes as a package-level passthru via legacyPackages
        legacyPackages.getnixes = getnixes;
      };
    };
}
