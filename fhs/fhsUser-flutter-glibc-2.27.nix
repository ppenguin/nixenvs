# fhsUser.nix
let
  pkgs = import (builtins.fetchGit {
    # glibc-2.27;                                                 
    url = "https://github.com/NixOS/nixpkgs/";                       
    ref = "refs/heads/nixpkgs-unstable";                     
    rev = "2158ec610d90359df7425e27298873a817b4c9dd";                                           
  }) {}; in
# { pkgs ? import <nixpkgs> {} }:
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
    gdk_pixbuf
    glib # libgio?
    # glib-networking
    epoxy 
    atk
    gtk3
  ];
  runScript = "bash";
}).env
