{ pkgs ? import <nixpkgs> {}
, unstable ? import <unstable> {}
}:

let
  inherit (pkgs) lib;
  myllvm = unstable.llvmPackages_15;
in
(unstable.mkShell.override { stdenv = myllvm.stdenv; }) {
  nativeBuildInputs = with unstable; [
    zig
    zls
    myllvm.bintools # https://matklad.github.io/2022/03/14/rpath-or-why-lld-doesnt-work-on-nixos.html
  ];

}