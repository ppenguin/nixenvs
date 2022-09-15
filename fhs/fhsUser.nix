# fhsUser.nix
{ pkgs ? import <nixpkgs> {} }:
(pkgs.buildFHSUserEnv {
  name = "stdxenv";
  targetPkgs = pkgs: with pkgs; [
    coreutils
  ];
  multiPkgs = pkgs: with pkgs; [
    zlib
    curl
    utillinux
    harfbuzz
    cairo
    pango
    gdk-pixbuf
    glib # libgio?
    # glib-networking
    epoxy 
    atk
    gtk3
  ];
  runScript = "${pkgs.zsh}/bin/zsh";
}).env