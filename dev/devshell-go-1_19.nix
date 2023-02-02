
{ pkgs ? import <nixpkgs> { config.allowUnfree = true; }
, unstable ? import <unstable> { config.allowUnfree = true; }
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    gnumake
    go_1_19 gopls delve
  ];
  # shellHook = ''
  # '';
}
