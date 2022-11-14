
{ pkgs ? import <nixpkgs> {}
, unstable ? import <unstable> {}
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    gnumake mono nodejs-18_x
    sqlite
  ] ++ (with unstable; [
    go_1_19 gopls
  ]);
  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.sqlite.out}/lib
  '';
}