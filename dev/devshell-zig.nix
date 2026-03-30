{pkgs ? import <nixpkgs> {}}: let
  myllvm = pkgs.llvmPackages;
in
  (unstable.mkShell.override {inherit (myllvm) stdenv;}) {
    nativeBuildInputs = with pkgs; [
      zig
      zls
      myllvm.bintools # https://matklad.github.io/2022/03/14/rpath-or-why-lld-doesnt-work-on-nixos.html
    ];
  }

