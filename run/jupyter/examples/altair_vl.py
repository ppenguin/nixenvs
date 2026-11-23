# ---
# jupyter:
#   jupytext:
#     formats: py:percent
#   kernelspec:
#     display_name: Python (altair)
#     language: python
#     name: altair
# ---

# %% [markdown]
# # altair (vega-lite)
# - declarative grammar: encodings + composition (`|`, `&`, `+`, facets) + linked selections, all client-side
# - notebook: default renderer = html + vega-embed from CDN; offline: `alt.renderers.enable("jupyter", offline=True)` (anywidget)
# - big data: `vegafusion` data transformer (aggregations run in python, not browser)
# - python-side selection state: `alt.JupyterChart` (anywidget)
# - separate window: `chart.show()` after `alt.renderers.enable("browser")`

# %%
from pathlib import Path

import altair as alt
import polars as pl

alt.data_transformers.enable("vegafusion")
gap = pl.read_csv(Path(globals().get("__file__", "_")).parent / "data/gapminder.csv.gz")  # notebook: cwd; panel serve: __file__

# %%
# linked brushing: drag on scatter -> filters histogram
brush = alt.selection_interval(encodings=["x"])
base = alt.Chart(gap.filter(pl.col("year") == 2007))

scatter = (
    base.mark_circle(size=60)
    .encode(
        x=alt.X("gdpPercap:Q", scale=alt.Scale(type="log")),
        y="lifeExp:Q",
        color=alt.condition(brush, "continent:N", alt.value("lightgray")),
        tooltip=["country", "continent", "lifeExp", "gdpPercap"],
    )
    .add_params(brush)
)
hist = base.mark_bar().encode(x=alt.X("lifeExp:Q", bin=alt.Bin(maxbins=25)), y="count()", color="continent:N").transform_filter(brush)

scatter | hist

# %%
# legend-click highlight + small multiples
pick = alt.selection_point(fields=["continent"], bind="legend")
(
    alt.Chart(gap.group_by("continent", "year").agg(pl.col("lifeExp").mean()))
    .mark_line(point=True)
    .encode(
        x="year:O",
        y="lifeExp:Q",
        color="continent:N",
        opacity=alt.condition(pick, alt.value(1), alt.value(0.15)),
    )
    .add_params(pick)
    .properties(width=500)
)

# %%
# JupyterChart: read the selection back in python
jc = alt.JupyterChart(scatter.properties(width=400))
jc

# %%
jc.selections  # re-run after brushing

# %%
# separate browser window (uncomment)
# alt.renderers.enable("browser"); (scatter | hist).show()
