{
    pkgs ? import <nixpkgs> {}
    ,unstable ? import <unstable> {}
}:
# !!! if using unstable, use it for all pkgs, otherwise library errors during build!
let
  epoxy = unstable.libepoxy;
  clang = unstable.clang;
in
pkgs.mkShell {
  buildInputs = with unstable; [
    at-spi2-core.dev
    dbus.dev
    gtk3
    libdatrie
    libselinux
    libsepol
    libthai
    libxkbcommon
    pcre
    pkg-config
    util-linux.dev
    xorg.libXdmcp
    xorg.libXtst
    ninja
    cmake
    dart
    flutter
  ]
  ++ [ epoxy clang ];
  shellHook = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${epoxy}/lib
    CC=${clang}/bin/clang
    CXX=${clang}/bin/clang++
  '';
}