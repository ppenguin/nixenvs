{
  pkgs ?
    import <nixpkgs> {
      config.documentation = {
        man.enable = false;
        doc.enable = false;
        info.enable = false;
      };
    },
}: let
  py = pkgs.python3;
  # below implies python interpreter itself, do not separately specify!
  pypkgs = [(py.withPackages (p: with p; [pexpect ansible-core jmespath ansible-lint]))];
  ansibleCollectionPath = pkgs.callPackage ./lib/ansible-collections.nix {} pkgs.ansible {
    "containers-podman" = {
      version = "1.19.0";
      sha256 = "sha256:117dwxwzn4r33sianmvq7jmlx25ri81xh8hca4dh1pmwjh03hk4l";
    };
  };
in
  pkgs.mkShell {
    buildInputs = with pkgs;
      [
        gnumake
        nodejs
      ]
      ++ pypkgs
      ++ (with pkgs.nodePackages; [
        yarn
      ]);
    shellHook = ''
      export ANSIBLE_COLLECTIONS_PATHS="${ansibleCollectionPath}"
      # export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
    '';
  }
