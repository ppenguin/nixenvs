{pkgs ? import <nixpkgs> {config.allowUnfree = true;}}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    yq
    jq
    nomad
    vault-bin
    opentofu
    hurl
    gnumake
    babashka # bb for experimental clojure scripting (first class json processing)
    postgresql # for psql
  ];
  # shellHook = ''
  # '';
}
