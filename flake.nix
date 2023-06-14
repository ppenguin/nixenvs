{
    description = "ppenguin's nix dev shells";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        flake-utils = {
            url = "github:numtide/flake-utils";
            # inputs.nixpkgs.follows = "nixpkgs-unstable";
        };
    };

    outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = nixpkgs.legacyPackages.${system};
                unstable = (import nixpkgs-unstable { inherit (pkgs) config; });
                inherit (pkgs) lib;

                getnixes = dir: prefix: (with builtins;
                    lib.attrNames
                        (lib.filterAttrs (n: v:
                            v == "regular" &&
                                (all (e: e)
                                    (map (pfun: pfun (baseNameOf n))
                                        [ (lib.hasPrefix prefix) (lib.hasSuffix ".nix") ]
                                    )
                                )
                        ) (readDir dir))
                );

                genshells = dir: prefix: (with builtins;
                    lib.genAttrs
                        (map (s:
                            (lib.removeSuffix ".nix" (lib.removePrefix prefix s))
                        ) (getnixes dir prefix))
                            (n: (import (dir + "/${prefix}${n}.nix") { inherit pkgs unstable; }))
                );

            in {
                # run-shells:
                testshell = import ./dev/test.nix { inherit pkgs; };

                # devshells generated from ./dev
                devShells = (genshells ./dev "devshell-") //
                    # more devshells
                    {
                        test = import ./dev/test.nix { inherit pkgs; };
                        # run-jupyter = import ./run/jupyter.nix { inherit pkgs; }; # FIXME: .nix broken
                        dev-fhs-simple = import ./dev/fhs-simple.nix { inherit pkgs unstable; };
                    };

                # test function
                getnixes = getnixes;
            }
        );
}