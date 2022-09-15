{ pkgs ? import <nixpkgs> {} }:

let
  envname = "fhsTestEnv";
  # myPkgs = with pkgs; (python310.withPackages (p: with p; [ pexpect ansible-core ansible-lint jmespath ]));
  myPkgs = with pkgs; [ zsh coreutils curl ];
  myEnv = pkgs.buildEnv {
    name = envname;
    paths = [ myPkgs ];
  };
in

(pkgs.buildFHSUserEnv {
  name = envname;
  targetPkgs = [ myEnv ];
  runScript = "${myPkgs.pkgs.zsh}/bin/zsh";
}).env