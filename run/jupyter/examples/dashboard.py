# hot-reload dashboard: `nix run .#panel-serve -- dashboard.py` -> edit/save -> browser reloads
# panel renders hvplot/bokeh, plotly, altair (vega) and matplotlib panes side by side
from pathlib import Path

import altair as alt
import hvplot.polars  # noqa: F401
import panel as pn
import plotly.express as px
import polars as pl

pn.extension("plotly", "vega")

gap = pl.read_csv(Path(globals().get("__file__", "_")).parent / "data/gapminder.csv.gz")  # notebook: cwd; panel serve: __file__

year = pn.widgets.IntSlider(name="year", start=1952, end=2007, step=5, value=2007)
continents = sorted(gap["continent"].unique().to_list())
cont = pn.widgets.MultiChoice(name="continents", options=continents, value=continents)


def sel(y, cs):
    return gap.filter((pl.col("year") == y) & pl.col("continent").is_in(cs))


@pn.depends(year, cont)
def plotly_view(y, cs):
    return px.scatter(sel(y, cs), x="gdpPercap", y="lifeExp", size="pop", color="continent",
                      hover_name="country", log_x=True, size_max=45, template="plotly_white",
                      category_orders={"continent": continents})


@pn.depends(year, cont)
def altair_view(y, cs):
    return (
        alt.Chart(sel(y, cs))
        .mark_bar()
        .encode(x=alt.X("lifeExp:Q", bin=alt.Bin(maxbins=20)), y="count()",
                color=alt.Color("continent:N", scale=alt.Scale(domain=continents)))
        .properties(width="container", height=300)
    )


@pn.depends(cont)
def hv_view(cs):
    d = gap.filter(pl.col("continent").is_in(cs)).group_by("continent", "year").agg(pl.col("lifeExp").mean()).sort("year")
    return d.hvplot.line(x="year", y="lifeExp", by="continent", height=300, responsive=True)


pn.template.FastListTemplate(
    title="gapminder: plotly | altair | hvplot",
    sidebar=[year, cont],
    main=[
        pn.Row(pn.Column("### plotly", plotly_view), pn.Column("### altair", altair_view, sizing_mode="stretch_width")),
        pn.Column("### hvplot", hv_view),
    ],
).servable()
