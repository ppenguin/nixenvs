{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs;
    [
      gnumake
      nodejs-18_x
    ]
    ++ (with pkgs.nodePackages; [
      yarn
    ]);
}

