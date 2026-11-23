# ---
# jupyter:
#   jupytext:
#     formats: py:percent
#   kernelspec:
#     display_name: Python (plotly)
#     language: python
#     name: plotly
# ---

# %% [markdown]
# # plotly express
# - one call per chart, df in -> interactive fig out (zoom/pan/hover/legend toggle)
# - notebook: renders inline (`jupyterlab-plotly` mimetype)
# - separate window: `fig.show(renderer="browser")` (static snapshot, no reload)
# - hot reload: see `dashboard.py` (`nix run .#panel-serve -- dashboard.py`)

# %%
from pathlib import Path

import plotly.express as px
import polars as pl

gap = pl.read_csv(Path(globals().get("__file__", "_")).parent / "data/gapminder.csv.gz")  # notebook: cwd; panel serve: __file__
gap.head()

# %%
# scatter + animation slider; px accepts polars directly (narwhals)
px.scatter(
    gap,
    x="gdpPercap",
    y="lifeExp",
    size="pop",
    color="continent",
    hover_name="country",
    animation_frame="year",
    log_x=True,
    size_max=50,
    range_y=[25, 90],
    template="plotly_white",
)

# %%
# faceted lines (small multiples > dual axes)
by_cont = gap.group_by("continent", "year").agg(pl.col("lifeExp").mean()).sort("year")
px.line(by_cont, x="year", y="lifeExp", color="continent", markers=True, template="plotly_white")

# %%
# distribution, marginals for free
px.histogram(
    gap.filter(pl.col("year") == 2007),
    x="lifeExp",
    color="continent",
    marginal="box",
    nbins=30,
    template="plotly_white",
)

# %%
# FigureWidget: python-side callbacks (anywidget) -> e.g. react to selections
import plotly.graph_objects as go

df07 = gap.filter(pl.col("year") == 2007)
fw = go.FigureWidget(px.scatter(df07, x="gdpPercap", y="lifeExp", hover_name="country", log_x=True))


def on_select(trace, points, _):
    print("selected:", [df07["country"][i] for i in points.point_inds])


fw.data[0].on_selection(on_select)
fw

# %%
# separate browser window (uncomment)
# fig.show(renderer="browser")
