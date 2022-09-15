{
    description = "ppenguin's nix dev shells";

    inputs.flake-utils.url = "github:numtide/flake-utils";

    outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = nixpkgs.legacyPackages.${system};
            in {
                devShells.default = import ./shell-test.nix { inherit pkgs; };
                devShells.jupyter = import ./jupyterWith/shell.nix { inherit pkgs; };
                devShells.fhstest = import ./shell-fhs.nix { inherit pkgs; };
            }
        );
}