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
}
