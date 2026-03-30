{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs;
    [
      gnumake
      nodejs-16_x
    ]
    ++ (with pkgs.nodePackages; [
      yarn
    ]);
}

