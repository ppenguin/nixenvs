{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
    buildInputs = [
        nixpkgs-fmt
    ];

    shellHook = ''
        export TESTVAR=testvalue
    '';
}