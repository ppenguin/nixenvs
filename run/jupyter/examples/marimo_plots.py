# reactive notebook (plain .py): `nix run .#marimo-plots -- edit --watch marimo_plots.py`
# app mode, hot reload on file save: `nix run .#marimo-plots -- run --watch marimo_plots.py`
import marimo

__generated_with = "0.25.1"
app = marimo.App(width="medium")


@app.cell
def _():
    import altair as alt
    import marimo as mo
    import plotly.express as px
    import polars as pl

    gap = pl.read_csv(mo.notebook_dir() / "data/gapminder.csv.gz")
    return alt, gap, mo, pl, px


@app.cell
def _(mo):
    year = mo.ui.slider(1952, 2007, step=5, value=2007, label="year")
    year
    return (year,)


@app.cell
def _(alt, gap, mo, pl, year):
    # selections flow back into python reactively (chart.value = selected rows)
    chart = mo.ui.altair_chart(
        alt.Chart(gap.filter(pl.col("year") == year.value))
        .mark_circle(size=60)
        .encode(x=alt.X("gdpPercap:Q", scale=alt.Scale(type="log")), y="lifeExp:Q", color="continent:N", tooltip=["country"])
    )
    chart
    return (chart,)


@app.cell
def _(chart):
    chart.value  # brush in the chart above -> this table updates
    return


@app.cell
def _(gap, mo, pl, px, year):
    fig = mo.ui.plotly(px.scatter(gap.filter(pl.col("year") == year.value), x="gdpPercap", y="lifeExp", color="continent", hover_name="country", log_x=True, template="plotly_white"))
    fig
    return (fig,)


@app.cell
def _(fig):
    fig.value  # box/lasso select in plotly -> selected points
    return


if __name__ == "__main__":
    app.run()
