{pkgs ? import <nixpkgs> {}}: let
  epoxy = pkgs.libepoxy;
  inherit (pkgs) clang;
in
  pkgs.mkShell {
    buildInputs = with pkgs;
      [
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
      ++ [epoxy clang];
    shellHook = ''
      export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${epoxy}/lib
      CC=${clang}/bin/clang
      CXX=${clang}/bin/clang++
    '';
  }

