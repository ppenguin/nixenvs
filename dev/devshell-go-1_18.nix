
{ pkgs ? import <nixpkgs> { config.allowUnfree = true; }
, unstable ? import <unstable> { config.allowUnfree = true; }
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    gnumake
  ] ++ (with unstable; [
    go_1_18 gopls delve
  ]);
  # shellHook = ''
  # '';
}
