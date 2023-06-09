{ pkgs ? import <nixpkgs> {}
, unstable ? import <unstable> {}
}:
# !!! if using unstable, use it for all pkgs, otherwise library errors during build!
let
  inherit (pkgs) lib;
  # myllvm = unstable.llvmPackages_15;
  py = unstable.python310;
  pypkgs = [ (py.withPackages (p: with p; [ numpy pint ]))];
in
(unstable.mkShell /* .override { stdenv = myllvm.stdenv; }*/) {
  nativeBuildInputs = with unstable; [
    zlib
    codon
  ] ++ pypkgs;

  # shellHook = ''
  # '';
}