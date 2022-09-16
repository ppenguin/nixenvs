{ pkgs ? import <nixpkgs> {} }:

let
  envname = "fhsTestEnv";
  # myPkgs = with pkgs; (python310.withPackages (p: with p; [ pexpect ansible-core ansible-lint jmespath ]));
  # myPkgs = with pkgs; [ zsh coreutils curl ];
  myEnv = pkgs.buildEnv {
    name = envname;
    paths = [ pkgs.zsh ];
  };
in

(pkgs.buildFHSUserEnv {
  name = envname;
  targetPkgs = pkgs: with pkgs; [ myEnv ];
  runScript = "${pkgs.zsh}/bin/zsh";
}).env