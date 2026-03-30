{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib;
  libdeflate = pkgs.callPackage ../pkgs/libdeflate {};
  inherit (pkgs) libepoxy;
  myllvm = pkgs.llvmPackages;

  libs = with pkgs;
    [
      atk
      at-spi2-core.dev
      dbus.dev
      gtk3
      pango
      cairo
      harfbuzz
      gdk-pixbuf
      glib # these are transitive but explicit here for the LD_LIBRARY_PATH
      fontconfig
      libdatrie
      libselinux
      libsepol
      pcre
      libthai
      libxkbcommon
      pcre2
      util-linux.dev
      xorg.libX11.dev
      xorg.libXdmcp
      xorg.libXtst
      libappindicator.dev
      libsecret.dev
      libgcrypt.dev
      jsoncpp.dev
      libgpg-error.dev
    ]
    ++ [
      libepoxy
      libdeflate
    ];
in
  (pkgs.mkShell.override {inherit (myllvm) stdenv;}) {
    nativeBuildInputs = with pkgs;
      [
        pkg-config
        ninja
        cmake
        dart
        flutter
        go_1_18
      ]
      ++ [
        myllvm.bintools # https://matklad.github.io/2022/03/14/rpath-or-why-lld-doesnt-work-on-nixos.html
      ];

    buildInputs =
      libs
      ++ (with myllvm; [
        libcxxClang
        libunwind
      ]);

    shellHook = ''
      export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${lib.makeLibraryPath [libepoxy]}
    '';
  }

