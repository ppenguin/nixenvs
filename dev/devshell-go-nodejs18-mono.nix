{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    gnumake
    mono
    nodejs-18_x
    yarn
    sqlite
    go
    gopls
  ];
  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.sqlite.out}/lib
  '';
}
