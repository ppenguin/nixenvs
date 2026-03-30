{pkgs ? import <nixpkgs> {config.allowUnfree = true;}}:
pkgs.mkShell {
  hardeningDisable = ["fortify"];
  buildInputs = with pkgs; [
    gnumake
    go
    gopls
    delve
  ];
  # shellHook = ''
  # '';
}
