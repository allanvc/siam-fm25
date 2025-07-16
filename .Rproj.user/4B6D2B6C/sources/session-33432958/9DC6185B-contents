import plotly.graph_objects as go
import pandas as pd
import numpy as np

# Parameters and simulated data
total_days = 200
forming_days = 50
decision_days = 5
trading_days = 5
stabilize_frames = 10  # Number of frames to expand only the trading rectangle

np.random.seed(123)
dates = pd.date_range(start="2023-01-01", periods=total_days, freq='D')
price = np.cumsum(np.random.randn(total_days))  # Generate simulated price data
data = pd.DataFrame({"Date": dates, "Price": price})

# Function to generate rectangle data for each frame
def generate_rectangles(start_date, forming_days, decision_days, trading_days, min_price, max_price):
    return [
        # Forming period
        dict(type="rect", x0=start_date, x1=start_date + pd.Timedelta(days=forming_days), 
             y0=min_price, y1=max_price, fillcolor="rgba(255, 0, 0, 0.3)", line=dict(width=0)),
        # Decision period
        dict(type="rect", x0=start_date + pd.Timedelta(days=forming_days), 
             x1=start_date + pd.Timedelta(days=forming_days + decision_days), 
             y0=min_price, y1=max_price, fillcolor="rgba(0, 255, 0, 0.3)", line=dict(width=0)),
        # Trading period
        dict(type="rect", x0=start_date + pd.Timedelta(days=forming_days + decision_days), 
             x1=start_date + pd.Timedelta(days=forming_days + decision_days + trading_days), 
             y0=min_price, y1=max_price, fillcolor="rgba(0, 0, 255, 0.3)", line=dict(width=0))
    ]

# Initialize frames
frames = []
for i in range(total_days - forming_days - decision_days - trading_days):
    end_index = forming_days + decision_days + trading_days + i  # Incrementally extend the line
    current_date = dates[i]

    # Generate the current rectangles and frame data
    frames.append(go.Frame(
        data=[go.Scatter(x=data["Date"][:end_index], y=data["Price"][:end_index], mode="lines", name="Price")],
        layout=go.Layout(
            shapes=generate_rectangles(current_date, forming_days, decision_days, trading_days, min(price), max(price))
        )
    ))

# Main plot configuration with initial 60 days of the line and full x-axis
fig = go.Figure(
    data=[go.Scatter(x=data["Date"][:forming_days + decision_days + trading_days], 
                     y=data["Price"][:forming_days + decision_days + trading_days], 
                     mode="lines", name="Price")],
    layout=go.Layout(
        title="Sliding Window with Incremental Line",
        xaxis=dict(title="Date", range=[dates[0], dates[-1]]),  # Full x-axis displayed
        yaxis=dict(title="Price"),
        plot_bgcolor="white",
        updatemenus=[dict(
            type="buttons", showactive=True,
            buttons=[dict(label="Play", method="animate", 
                          args=[None, {"frame": {"duration": 1500, "redraw": True}, "fromcurrent": True}])]
        )]
    ),
    frames=frames
)

# Add dummy points for the legend
fig.add_trace(go.Scatter(x=[None], y=[None], mode="markers", marker=dict(size=10, color="rgba(255, 0, 0, 0.3)"), name="Formation"))
fig.add_trace(go.Scatter(x=[None], y=[None], mode="markers", marker=dict(size=10, color="rgba(0, 255, 0, 0.3)"), name="Decision"))
fig.add_trace(go.Scatter(x=[None], y=[None], mode="markers", marker=dict(size=10, color="rgba(0, 0, 255, 0.3)"), name="Trading"))

# Save the plot as HTML
fig.write_html("incremental_line_with_sliding_rectangles.html")

# Show the plot
fig.show()
