
{ pkgs ? import <nixpkgs> {}
, unstable ? import <unstable> {}
}:

let
  # extraVSCE = unstable.buildEnv {
  #   name = "nix-shell-extra-vscode-extensions";
  #   paths = (with unstable.vscode-extensions; [
  #     christian-kohler.path-intellisense
  #     influxdata.flux # just to test more than one
  #   ]);
  #   pathsToLink = [ "/share/vscode/extensions" ];
  # };

  # mkSymlinks = pkgs.runCommand "mkSymlinks" { preferLocalBuild = true; } ''
  #   ln -s ${extraVSCE}/share/vscode/extensions/* ${builtins.getEnv "HOME"}/.vscode/extensions/
  # '';

in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    gnumake nodejs-16_x
  ] ++ (with pkgs.nodePackages; [
    yarn
  ]);

  # *** No easy way to add vscode extensions from a nix-shell, but interesting case;
  # maybe need a simple builder that simply symlinks realisations of extensions to ~/.vscode/extensions/
  # however this doesn't work
  # export CHECKVSCE="${extraVSCE}"
  # ln -sf $(readlink ${extraVSCE}/share/vscode/extensions/*) ${builtins.getEnv "HOME"}/.vscode/extensions/

  # shellHook = ''
  #   # export SSH_AUTH_SOCK=/run/user/$UID/keyring/ssh
  #   # export GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt
  #   # export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
  # '';
}