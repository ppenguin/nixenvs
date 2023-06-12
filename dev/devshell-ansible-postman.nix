{ pkgs ? import <nixpkgs> { config.allowUnfree = true;  config.documentation = { man.enable = false; doc.enable = false; info.enable = false; }; }
, unstable ? import <unstable> { config.allowUnfree = true;  config.documentation = { man.enable = false; doc.enable = false; info.enable = false; }; }
}:

let
  py = pkgs.python310;
  # below implies python interpreter itself, do not separately specify!
  pypkgs = [ (py.withPackages (p: with p; [ pexpect ansible-core jmespath ]))];
  ansibleCollectionPath = pkgs.callPackage ./lib/ansible-collections.nix {} pkgs.ansible {
    "containers-podman" = {
        version = "1.9.4";
        sha256 = "sha256:1g74pi0fslgbcp80710q42pfaifiai9hwaz69mi1bm8lqiz79ip8";
    };
  };
in

pkgs.mkShell {
  buildInputs = with pkgs; [
    postman
    ansible-lint
  ] ++ pypkgs;
  shellHook = ''
    export ANSIBLE_COLLECTIONS_PATHS="${ansibleCollectionPath}"
  '';
}