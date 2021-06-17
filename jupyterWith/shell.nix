let
  jupyter = import (builtins.fetchGit {
    url = https://github.com/tweag/jupyterWith;
    rev = "0940c0d8ff3dbbae8395c138a89a57fd2cdb509c";
  }) {};

  ihaskell = jupyter.kernels.iHaskellWith {
    name = "haskell";
    packages = p: with p; [ hvega formatting ];
  };

  ipython = jupyter.kernels.iPythonWith {
    name = "python";
    packages = p: with p; [ numpy ];
  };

  jupyterEnvironment = jupyter.jupyterlabWith {
    kernels = [ ihaskell ipython ];
  };
in
  jupyterEnvironment.env