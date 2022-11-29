{ pkgs ? import <nixpkgs> {}
, unstable ? import <unstable> {}
}:

let
  libdeps = pkgs.buildEnv {
    name = "libdeps";
    paths = with pkgs; [
      glib.out glib.dev gtk3.dev gdk-pixbuf.dev pango.dev cairo.dev harfbuzz.dev atk.dev
      libsoup.dev webkitgtk.dev
      zlib.out zlib.dev
    ] ;
  };
in

pkgs.mkShell {
  nativeBuildInputs = with unstable; [ rustc cargo cargo-graph cargo-edit /* gcc */ ];
  buildInputs = with unstable; [ rustfmt clippy libdeps ];

  # Certain Rust tools won't work without this
  # This can also be fixed by using oxalica/rust-overlay and specifying the rust-src extension
  # See https://discourse.nixos.org/t/rust-src-not-found-and-other-misadventures-of-developing-rust-on-nixos/11570/3?u=samuela. for more details.
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  PKG_CONFIG_PATH = "${libdeps}/lib/pkgconfig";
}