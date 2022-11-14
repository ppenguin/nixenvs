
{ pkgs ? import <nixpkgs> { config.allowUnfree = true; }
, unstable ? import <unstable> { config.allowUnfree = true; }
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    gnumake mono nodejs-18_x yarn
    sqlite
    postman
  ] ++ (with unstable; [
    go_1_18 gopls
    # delve !!! probably enforce this: go get github.com/go-delve/delve, which might work to solve this issue: https://github.com/microsoft/vscode-go/issues/1421
  ]);
  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.sqlite.out}/lib
  '';
}