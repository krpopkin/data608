import pandas as pd
import numpy as np

import dash
import dash_html_components as html
import dash_core_components as dcc
from dash.dependencies import Input, Output

from plotly.subplots import make_subplots
import plotly.graph_objects as go
import plotly.express as px

# Load data
data = pd.read_csv("module4_data.csv")
data = data.dropna(how='any', axis=0)

# Create tree type dropdown data
tree_types = sorted(list(set(data.spc_common.values)))

# Create health data
health = data[['boroname', 'spc_common', 'health', 'steward']]
health = health.groupby(['boroname', 'spc_common', 'health']).count()
health = health.reset_index()
health.columns = ['boroname', 'tree', 'health', 'count']

# Create stewardship data
stewardship = data[['boroname', 'spc_common', 'health', 'steward']]
stewardship = stewardship.groupby(
    ['boroname', 'spc_common', 'steward']).count()
stewardship = stewardship.reset_index()
stewardship.columns = ['boroname', 'tree', 'steward', 'count']

# Run dash app
app = dash.Dash(__name__)

fig_dropdown = html.Div([
    dcc.Dropdown(
        id='tree_types_dropdown',
        options=[{'label': x, 'value': x} for x in tree_types],
        value=None
    )])

fig_plot = html.Div(id='fig_plot')
app.layout = html.Div([fig_dropdown, fig_plot])


@app.callback(
    dash.dependencies.Output('fig_plot', 'children'),
    [dash.dependencies.Input('tree_types_dropdown', 'value')])
def update_output(tree_name):
    return name_to_figure(tree_name)


def name_to_figure(tree_name):
    selected_health_tree = health[health.tree == tree_name]
    selected_steward_tree = stewardship[stewardship.tree == tree_name]

    figure = make_subplots(
        rows=1, cols=2, subplot_titles=('Health', 'Stewardship'))

    bar1 = px.bar(selected_health_tree, x="boroname",
                  y="count", color="health")

    #     bar2 = px.bar(selected_steward_tree, x="boroname",
    #                   y="count", color="steward")

    bar2 = px.line(selected_steward_tree, x='boroname',
                   y='count', color='steward')

    # figure.add_trace(go.Bar(
    #     x=selected_health_tree['boroname'], y=selected_health_tree['count']), row=1, col=1)

    for trace in bar1.data:
        figure.add_trace(trace, 1, 1)

    # figure.add_trace(go.Bar(
    #    x=selected_steward_tree['boroname'], y=selected_steward_tree['count']), row=1, col=2)
    for trace in bar2.data:
        figure.add_trace(trace, 1, 2)

    figure.update_layout(barmode="stack")
    return dcc.Graph(figure=figure)


app.run_server(debug=False)
