{
    description = "ppenguin's nix dev shells";

    inputs.flake-utils.url = "github:numtide/flake-utils";

    outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = nixpkgs.legacyPackages.${system};
            in {
                # TODO: is a run shell different?
                devShells.default = import ./dev/test.nix { inherit pkgs; };
                devShells.run-jupyter = import ./run/jupyter.nix { inherit pkgs; };
                devShells.dev-fhs-simple = import ./dev/fhs-simple.nix { inherit pkgs; };
                devShells.dev-ansible = import ./dev/ansible.nix { inherit pkgs; };
            }
        );
}