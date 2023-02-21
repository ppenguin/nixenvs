{ pkgs ? import <nixpkgs> {}
, unstable ? import <unstable> {}
}:
# !!! if using unstable, use it for all pkgs, otherwise library errors during build!
let
  inherit (pkgs) lib;
  # clang = unstable.clang_14;
  libs = with unstable; [
    at-spi2-core.dev
    dbus.dev
    gtk3
    libdatrie
    libselinux
    libepoxy
    libsepol
    libthai
    libxkbcommon
    pcre
    pcre2
    util-linux.dev
    xorg.libX11.dev
    xorg.libXdmcp
    xorg.libXtst
    libappindicator.dev
  ] ++ [ (unstable.callPackage ../pkgs/libdeflate {}) ];
in
(pkgs.mkShell.override { stdenv = unstable.llvmPackages_14.stdenv; }) {
  nativeBuildInputs = with unstable; [
    gtk3
    xorg.libX11.dev
    pkg-config
    ninja
    cmake
    dart
    flutter
    go_1_18
  ];

  buildInputs = libs;

  # ++
  # (with unstable.llvmPackages_14; [
  #   bintools
  #   clangUseLLVM
  # ]);
  shellHook = ''
    LD_LIBRARY_PATH=${lib.makeLibraryPath libs}
    LD=lld
    # CC=clang
    # CXX=clang++
  '';
}