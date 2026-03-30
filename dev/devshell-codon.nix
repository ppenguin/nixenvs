{pkgs ? import <nixpkgs> {}}:
# !!! if using pkgs, use it for all pkgs, otherwise library errors during build!
let
  py = pkgs.python3;
  pypkgs = [(py.withPackages (p: with p; [numpy pint]))];
in
  pkgs.mkShell
  /*
  .override { stdenv = myllvm.stdenv; }
  */
  {
    nativeBuildInputs = with pkgs;
      [
        zlib
        codon
      ]
      ++ pypkgs;

    # shellHook = ''
    # '';
  }

