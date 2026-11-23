# ---
# jupyter:
#   jupytext:
#     formats: py:percent
#   kernelspec:
#     display_name: Python (holoviz)
#     language: python
#     name: holoviz
# ---

# %% [markdown]
# # hvplot / holoviews / panel (bokeh backend)
# - `df.hvplot.<kind>(...)`: pandas-like one-liners -> interactive bokeh plots
# - `groupby=` -> auto widgets; `*` overlay, `+` layout; `datashade=True` for millions of points
# - notebook: inline (pyviz_comms labextension)
# - hot reload, same file: `nix run .#panel-serve -- holoviz.py` (renders `.servable()` objects)

# %%
from pathlib import Path

import hvplot.polars  # noqa: F401  registers .hvplot on polars frames
import numpy as np
import panel as pn
import polars as pl

pn.extension()
gap = pl.read_csv(Path(globals().get("__file__", "_")).parent / "data/gapminder.csv.gz")  # notebook: cwd; panel serve: __file__

# %%
# groupby -> year slider widget, generated
scatter = gap.hvplot.scatter(
    x="gdpPercap",
    y="lifeExp",
    by="continent",
    size="pop",
    scale=0.002,
    logx=True,
    groupby="year",
    hover_cols=["country"],
    ylim=(25, 90),
    width=700,
    height=400,
    widget_location="bottom",
)
scatter

# %%
# composition: `+` layout (shared axes -> linked zoom)
by_cont = gap.group_by("continent", "year").agg(pl.col("lifeExp").mean(), pl.col("pop").sum()).sort("year")
life = by_cont.hvplot.line(x="year", y="lifeExp", by="continent", width=450, height=300)
pop = by_cont.hvplot.area(x="year", y="pop", by="continent", stacked=True, width=450, height=300)
(life + pop).cols(2)

# %%
# datashader: 2M points, rasterized server-side
n = 2_000_000
pts = pl.DataFrame({"x": np.random.standard_normal(n), "y": np.random.standard_normal(n) * 0.5 + np.random.standard_normal(n) ** 2 * 0.3})
dense = pts.hvplot.points("x", "y", rasterize=True, cmap="viridis", width=500, height=400)
dense

# %%
# servable: what `panel serve` shows
pn.Column("# gapminder (hvplot)", scatter, life + pop, dense).servable(title="holoviz demo")
