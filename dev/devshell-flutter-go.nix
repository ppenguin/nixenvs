{ pkgs ? import <nixpkgs> {}
, unstable ? import <unstable> {}
}:
# !!! if using unstable, use it for all pkgs, otherwise library errors during build!
let
  inherit (pkgs) lib;
  libdeflate = unstable.callPackage ../pkgs/libdeflate {};
  libepoxy = unstable.libepoxy;
  myllvm = unstable.llvmPackages_14;

  libs = with unstable; [
    atk at-spi2-core.dev
    dbus.dev
    gtk3
    pango cairo harfbuzz gdk-pixbuf glib # these are transitive but explicit here for the LD_LIBRARY_PATH
    fontconfig
    libdatrie
    libselinux libsepol pcre
    libthai
    libxkbcommon
    pcre2
    util-linux.dev
    xorg.libX11.dev xorg.libXdmcp xorg.libXtst
    libappindicator.dev
  ] ++ [
    libepoxy
    libdeflate
  ];
in
(unstable.mkShell.override { stdenv = myllvm.stdenv; }) {
  nativeBuildInputs = with unstable; [
    pkg-config
    ninja
    cmake
    dart
    flutter
    go_1_18
  ] ++ [
    myllvm.bintools # https://matklad.github.io/2022/03/14/rpath-or-why-lld-doesnt-work-on-nixos.html
  ];

  buildInputs = libs ++ (with myllvm; [
    libcxxClang
    libunwind
  ]);

  shellHook = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${lib.makeLibraryPath [ libepoxy ]}
  '';
}