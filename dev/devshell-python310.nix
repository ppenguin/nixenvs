{ pkgs ? import <nixpkgs> { }
, unstable ? import <unstable> { }
}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    python310Packages.python
    poetry
  ];
}
