
{ pkgs ? import <nixpkgs> { config.allowUnfree = true; }
, unstable ? import <unstable> { config.allowUnfree = true; }
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    gnumake mono nodejs-16_x yarn
    sqlite
    postman
    docker-compose
  ] ++ (with unstable; [
    go_1_18 gopls delve
  ]);
  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.sqlite.out}/lib
  '';
}
