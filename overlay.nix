final: prev: {
  # TODO: not exactly clear which attributes we want to override in the end...
  platformioPackages = dontRecurseIntoAttrs (callPackage ../development/embedded/platformio {});
  platformio =
    if prev.stdenv.isLinux
    then prev.platformioPackages.platformio-chrootenv
    else prev.platformioPackages.platformio-core;
  # platformio-core = prev.platformioPackages.platformio-core;
  python3Packages = prev.python3Packages.override {
    packageOverrides = pyfinal: pyprev: {
      platformio = pyfinal.callPackage ./pkgs/development/python-modules/platformio {};
    };
  };
}
