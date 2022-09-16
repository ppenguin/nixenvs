{ pkgs ? import <nixpkgs> {} }:

let
  myPkgs = with pkgs; (python310.withPackages (p: with p; [ pexpect ansible-core ansible-lint jmespath ]));
  myEnv = pkgs.buildEnv {
    name = "ansible-env";
    paths = [ myPkgs ];
  };
  ansibleCollectionPath = pkgs.callPackage ../util/ansible-collections.nix {} myPkgs.pkgs.ansible-core {
    "containers-podman" = {
        version = "1.9.3";
        sha256 = "sha256:1vjsm7696fp9av7708h05zjjdil7gwcqiv6mrz7vzmnnwdnqshp7";
    };
  };
in

pkgs.mkShell {
  nativeBuildInputs = [ myEnv ];
  shellHook = ''
    export ANSIBLE_COLLECTIONS_PATHS="${ansibleCollectionPath}"
    ### are the below still necessary?
    # export SSH_AUTH_SOCK=/run/user/$UID/keyring/ssh
    # export GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt
    # export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
  '';
}