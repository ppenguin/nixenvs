{pkgs ? import <nixpkgs> {}}: let
  envname = "fhsTestEnv";
  # myPkgs = with pkgs; (python3.withPackages (p: with p; [ pexpect ansible-core ansible-lint jmespath ]));
  # myPkgs = with pkgs; [ zsh coreutils curl ];
  myEnv = pkgs.buildEnv {
    name = envname;
    paths = [pkgs.zsh];
  };
in
  (pkgs.buildFHSEnv {
    name = envname;
    targetPkgs = pkgs: [myEnv];
    runScript = "${pkgs.zsh}/bin/zsh";
    # zsh's etc/zshenv.zwc (compiled global zshenv: `. /etc/zshenv`) would land in the rootfs /etc
    # -> zsh prefers /etc/zshenv.zwc over the host /etc/zshenv -> infinite self-source
    extraBuildCommands = ''
      rm -f $out/etc/zshenv.zwc $out/etc/zshenv_zwc_is_used
    '';
  })
  .env
