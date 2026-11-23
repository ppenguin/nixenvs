# plotting envs

[kirelagin/jupyter.nix](https://github.com/kirelagin/jupyter.nix) labs + hot-reload servers; nixpkgs = nixos-den's pin.

## devshell (recommended: lab + agent/editor share one env)

devShells (= lab names): `jupyter-plots` (alias `plots`), `jupyter-plotly`, `jupyter-altair`, `jupyter-holoviz`

```sh
cd ~/my-notebooks
nix develop github:ppenguin/nixenvs#jupyter-plots   # or local: nix develop ~/devel/github.com/ppenguin/nixenvs#jupyter-plots
jupyter-lab &      # same as `nix run .#jupyter-plots`
claude             # sees same python/libs/jupytext/kernel
```

- direnv: `.envrc` -> `use flake github:ppenguin/nixenvs#jupyter-plots`
- PATH: `jupyter*`, `jupytext` (lab's, w/ pairing cfg), `python` (= kernel libs), `panel`, `marimo` (plots only)
- `jupyter kernelspec list` -> only the lab's kernel (e.g. `plots`)

## run (no shell)

```sh
cd run/jupyter/examples          # lab/servers use cwd
nix run ../../..#jupyter-plots      # all libs, 1 kernel "plots"
nix run ../../..#jupyter-plotly     # plotly express (+ FigureWidget)
nix run ../../..#jupyter-altair     # altair + vegafusion + JupyterChart
nix run ../../..#jupyter-holoviz    # hvplot/holoviews/bokeh/panel/datashader

nix run ../../..#panel-serve -- dashboard.py            # hot reload: save -> browser reloads
nix run ../../..#panel-serve -- holoviz.py              # same notebook file, served
nix run ../../..#marimo-plots -- edit --watch marimo_plots.py
nix run ../../..#jupytext -- --sync nb.ipynb            # jupytext CLI (plots kernel)
```

- remote: `nix run github:ppenguin/nixenvs#jupyter-plots`
- extra args -> `jupyter-lab` (e.g. `--no-browser --port 8899`)

## notebooks = `# %%` .py (jupytext)

- auto pairing (global default, wrapped lab/jupytext): `formats = "ipynb,py:percent"`
  - save `nb.ipynb` in lab -> `nb.py` twin written; outputs stay in .ipynb
  - edit `nb.py` (editor/agent) -> lab: File -> Reload Notebook from Disk (inputs from .py, outputs kept)
  - CLI: `jupytext --sync nb.py`; execute: `jupytext --to ipynb --execute nb.py`
  - override per project: `jupytext.toml` in nb dir/parents (or `~/.config/jupytext/`)
- `.py` in lab: right-click -> Open With -> Notebook
- git-friendly diffs; same file runnable via `python`, `panel serve`

### CLAUDE.md snippet (for notebook projects)

```md
- notebooks: edit the paired `# %%` `.py`, never the `.ipynb` directly
- after editing: `jupytext --sync <nb>.py` (keeps outputs); to run: `jupytext --to ipynb --execute <nb>.py`
- scripts/one-offs: `python` in this shell has the kernel's libs
```

## examples

| file | lib | shows |
|---|---|---|
| `plotly_px.py` | plotly express | animation slider, marginals, FigureWidget selection callback |
| `altair_vl.py` | altair | linked brush, legend highlight, JupyterChart selections -> python |
| `holoviz.py` | hvplot | `groupby=` auto widgets, `+` layouts, datashader 2M pts, `.servable()` |
| `dashboard.py` | panel | plotly + altair + hvplot panes, shared widgets, hot reload |
| `marimo_plots.py` | marimo | reactive: slider/brush/lasso -> dependent cells re-run |

data: `examples/data/gapminder.csv.gz` (from plotly's bundled datasets, MIT)

## lib tradeoffs

| | one-liner DX | interactivity | linked/selections | big data | hot-reload window |
|---|---|---|---|---|---|
| plotly express | best (`px.<kind>(df, ...)`) | hover/zoom/anim built-in | FigureWidget callbacks | webgl ~1M | via panel/marimo/dash |
| altair | declarative, verbose for tweaks | good | best (client-side, declarative) | vegafusion | via panel/marimo |
| hvplot | pandas-like (`df.hvplot.<kind>`) | widgets from `groupby=` | linked zoom, streams | datashader (∞) | `panel serve --dev` native |
| marimo | n/a (host) | reactive cells | `mo.ui.{altair_chart,plotly}` -> python | — | `--watch` native |

- notebook-first, simplest: plotly express
- notebook <-> dashboard same file, hot reload, huge data: hvplot + panel
- reactive notebook in plain .py w/ hot reload: marimo (+ plotly/altair)

## overlay fixes (nixpkgs-weekly f4a03c00, drop when upstream fixed)

- `panel` 1.9.4 -> 1.10.0 (1.9 import-crashes on bokeh 3.10); `panel-material-ui` dep removed (unpackaged)
- `vegafusion`: + pkg-config, zstd
- `marimo`: relax `uv_build<0.13` build dep

## notes

- altair 6 default renderer: html + vega-embed via CDN; offline -> `alt.renderers.enable("jupyter", offline=True)`
- `fig.show(renderer="browser")` / altair `browser` renderer: one-shot window, no reload
