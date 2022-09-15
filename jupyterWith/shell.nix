let
  jupyter = import (builtins.fetchGit {
    url = https://github.com/tweag/jupyterWith;
    rev = "deaa6c66165fd1ebe8617a8f133ad45110ac659c";
    # sha256="1gb0lbry4ch77dk7ararxhhbq7glib79kc45agzlc2632dfsl2pp";
  }) {};

  ihaskell = jupyter.kernels.iHaskellWith {
    name = "haskell";
    packages = p: with p; [ hvega formatting ];
  };

  ipython = jupyter.kernels.iPythonWith {
    name = "python";
    packages = p: with p; [ numpy pint ];
  };

  jupyterEnvironment = jupyter.jupyterlabWith {
    kernels = [ ihaskell ipython ];
  };
in
  jupyterEnvironment.env