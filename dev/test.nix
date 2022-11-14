{ pkgs ? import <nixpkgs> { }
, unstable ? import <unstable> { }
}:

with pkgs;

mkShell {
    buildInputs = [
        nixpkgs-fmt
    ] ++ (with unstable; [ hello ]);

    shellHook = ''
        export TESTVAR=testvalue
    '';
}