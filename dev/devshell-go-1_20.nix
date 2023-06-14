
{ pkgs ? import <nixpkgs> { config.allowUnfree = true; }
, unstable ? import <unstable> { config.allowUnfree = true; }
}:

pkgs.mkShell {
  hardeningDisable = [ "fortify" ];
  buildInputs = with pkgs; [
    gnumake
    go_1_20 gopls delve
  ];
  # shellHook = ''
  # '';
}
