# plotting prototypes: jupyter labs (kirelagin/jupyter.nix) + hot-reload servers
# usage: see ./README.md
{
  pkgs,
  jupyterLib,
}: let
  inherit (pkgs) lib;
  python = pkgs.python3;
  pyp = python.pkgs;

  # per-lib python pkg selectors
  basePkgs = pp: with pp; [numpy pandas polars pyarrow scipy];
  plotlyPkgs = pp: with pp; [plotly anywidget];
  altairPkgs = pp: with pp; [altair anywidget vegafusion vl-convert-python vega-datasets];
  holovizPkgs = pp: with pp; [hvplot holoviews bokeh panel datashader pyviz-comms param];
  allPkgs = pp: lib.concatMap (f: f pp) [basePkgs plotlyPkgs altairPkgs holovizPkgs];

  # per-lib labextensions (server side); plotly's handled by `withPlotly`
  altairExt = [pyp.anywidget pyp.jupyterlab-widgets];
  holovizExt = [pyp.pyviz-comms pyp.jupyterlab-widgets];

  # global jupytext config (lowest prio: jupytext.toml/pyproject in nb dir or parents, ~/.config/jupytext win)
  # -> every notebook saved in lab gets a `# %%` .py twin; edit either, other syncs on save/reload
  jupytextConfig = pkgs.writeTextDir "jupytext/jupytext.toml" ''
    formats = "ipynb,py:percent"
  '';

  mkLab = {
    name,
    packages,
    withPlotly ? false,
    labExtensions ? [],
    shellPackages ? _: [],
  }: let
    lab = jupyterLib.makeJupyterLab {
      inherit pkgs;
      kernels.${name}.ipykernel = {
        packages = pp: basePkgs pp ++ packages pp;
        inherit withPlotly;
      };
      # jupytext: open/pair `# %%` .py files as notebooks (git-friendly; also `panel serve`-able)
      jupyterEnvPackages = pp: [pp.jupytext];
      labExtensions = lib.unique ([pyp.jupytext] ++ labExtensions);
      settings.MappingKernelManager.default_kernel_name = name;
    };
  in
    # wrap entrypoints: prepend jupytextConfig to XDG_CONFIG_DIRS (keeping /etc/xdg default)
    pkgs.symlinkJoin {
      name = "jupyter-${name}";
      paths = [lab];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        for b in jupyter jupyter-lab jupyter-nbconvert jupytext; do
          wrapProgram "$out/bin/$b" \
            --run 'export XDG_CONFIG_DIRS="''${XDG_CONFIG_DIRS:-/etc/xdg}"' \
            --prefix XDG_CONFIG_DIRS : ${jupytextConfig}
        done
      '';
      passthru = {
        unwrapped = lab;
        # kernel libs + cli tools for the devShell (`python`, `panel`, ...); jupytext comes from the (wrapped) lab
        shellPython = python.withPackages (pp:
          basePkgs pp ++ packages pp ++ [pp.watchfiles] ++ shellPackages pp);
      };
      meta.mainProgram = "jupyter-lab";
    };

in rec {
  # jupyter labs
  jupyter-plotly = mkLab {
    name = "plotly";
    packages = plotlyPkgs;
    withPlotly = true;
  };
  jupyter-altair = mkLab {
    name = "altair";
    packages = altairPkgs;
    labExtensions = altairExt;
  };
  jupyter-holoviz = mkLab {
    name = "holoviz";
    packages = holovizPkgs;
    labExtensions = holovizExt;
  };
  jupyter-plots = mkLab {
    name = "plots";
    packages = allPkgs;
    withPlotly = true;
    labExtensions = altairExt ++ holovizExt;
    shellPackages = pp: [pp.marimo];
  };

  # one python env with everything (+ marimo), for servers/scripts outside jupyter
  plotsPython = jupyter-plots.shellPython;

  # hot-reload browser: `panel serve --dev` (file watch -> browser reload); args: files (.py/.ipynb)
  panel-serve = pkgs.writeShellApplication {
    name = "panel-serve";
    runtimeInputs = [plotsPython];
    text = ''exec panel serve --dev --show "$@"'';
  };

  # reactive notebooks (plain .py), e.g. `marimo edit --watch f.py`, `marimo run --watch f.py`
  marimo-plots = pkgs.writeShellApplication {
    name = "marimo";
    runtimeInputs = [plotsPython];
    text = ''exec marimo "$@"'';
  };

  # jupytext CLI w/ plots kernel + global pairing cfg, e.g. `--sync nb.ipynb`, `--to ipynb --execute nb.py`
  jupytext = pkgs.writeShellApplication {
    name = "jupytext";
    text = ''exec ${jupyter-plots}/bin/jupytext "$@"'';
  };
}
