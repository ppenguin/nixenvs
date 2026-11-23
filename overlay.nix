final: prev: {
  # TODO: not exactly clear which attributes we want to override in the end...
  platformioPackages = prev.dontRecurseIntoAttrs (prev.callPackage ./pkgs/development/embedded/platformio {});
  platformio =
    if prev.stdenv.isLinux
    then prev.platformioPackages.platformio-chrootenv
    else prev.platformioPackages.platformio-core;
  # platformio-core = prev.platformioPackages.platformio-core;
  # python3Packages = prev.python3Packages.overrideScope' (pyFinal: pyPrev: {
  #   platformio = pyFinal.callPackage ./pkgs/development/python-modules/platformio {};
  # });
  python3 = prev.python3.override {
    packageOverrides = pyFinal: pyPrev: {
      platformio = pyFinal.callPackage ./pkgs/development/python-modules/platformio {};
    };
  };

  # fixes for python pkgs broken in nixpkgs-weekly (f4a03c00); drop once fixed upstream
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: pyPrev: {
        # panel 1.9.4 breaks on bokeh 3.10 (import error) -> 1.10.0 (wheel, like nixpkgs)
        # new runtime deps; panel-material-ui unpackaged, only needed for pmui widgets/templates
        panel = pyPrev.panel.overridePythonAttrs (old: rec {
          version = "1.10.0";
          src = pyFinal.fetchPypi {
            pname = "panel";
            inherit version;
            format = "wheel";
            dist = "py3";
            python = "py3";
            hash = "sha256-Fcnyu1hWep42oiOWyzh3bfd+sMxSzZqZzrt4QksDY8A=";
          };
          dependencies = (old.dependencies or []) ++ [pyFinal.nh3];
          pythonRemoveDeps = (old.pythonRemoveDeps or []) ++ ["panel-material-ui"];
        });
        # vegafusion 2.0.3: zstd-sys build.rs needs pkg-config + libzstd
        vegafusion = pyPrev.vegafusion.overridePythonAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [final.pkg-config];
          buildInputs = (old.buildInputs or []) ++ [final.zstd];
        });
        # marimo 0.25: build-system pins uv_build<0.13, nixpkgs has 0.13.x
        marimo = pyPrev.marimo.overridePythonAttrs (old: {
          postPatch =
            (old.postPatch or "")
            + ''
              substituteInPlace pyproject.toml \
                --replace-fail 'uv_build>=0.8.3,<0.13.0' 'uv_build>=0.8.3'
            '';
        });
      })
    ];
}
