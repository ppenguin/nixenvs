
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    go_1_17 gnumake mono nodejs-16_x
    sqlite # for duplicati/mono
    lsd # for convenience
  ];
  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.sqlite.out}/lib
  '';
}