import plotly.graph_objects as go
import pandas as pd
import numpy as np

# Parameters and simulated data
total_days = 200
forming_days = 50
decision_days = 2
trading_days = 2
stabilize_frames = 10  # Number of frames for trading expansion

np.random.seed(123)
dates = pd.date_range(start="2023-01-01", periods=total_days, freq='D')
price = np.cumsum(np.random.randn(total_days))
z_scores = (price - np.mean(price)) / np.std(price)  # Convert price data to Z-score
data = pd.DataFrame({"Date": dates, "Zscore": z_scores})

# Midpoint and spike timing
midpoint_index = total_days // 2
spike_start = midpoint_index - 3
spike_end = spike_start + stabilize_frames

# Generate Z-score with a controlled spike, wavy return to zero, and bounded random variation
spike_z_scores = z_scores.copy()
spike_z_scores[spike_start] = 2.15  # Initial spike to 2.15
downward_trend = np.linspace(2.15, 0, stabilize_frames)  # Base trend back to zero

# Add wavy effect to return to zero over 10 frames
for i in range(1, stabilize_frames):
    noise = (-0.15 + np.random.rand() * 0.3)  # Small noise to create a wavy pattern
    spike_z_scores[spike_start + i] = downward_trend[i] + noise

# After the spike period, keep Z-score fluctuating randomly within ±2
for i in range(spike_start + stabilize_frames, total_days):
    spike_z_scores[i] = np.clip(np.random.randn() * 0.5, -2, 2)

# Function to generate rectangle data for each frame
def generate_rectangles(i, dates, forming_days, decision_days, trading_days, min_z, max_z, expand_trading=False, reset=False, reset_start_date=None):
    if reset and reset_start_date:
        # Reset positions after stabilization, aligning the upper bound of formation with trading's last upper bound
        return [
            dict(type="rect", x0=reset_start_date - pd.Timedelta(days=forming_days), x1=reset_start_date,
                 y0=min_z, y1=max_z, fillcolor="rgba(255, 0, 0, 0.3)", line=dict(width=0)),
            dict(type="rect", x0=reset_start_date,
                 x1=reset_start_date + pd.Timedelta(days=decision_days),
                 y0=min_z, y1=max_z, fillcolor="rgba(0, 255, 0, 0.3)", line=dict(width=0)),
            dict(type="rect", x0=reset_start_date + pd.Timedelta(days=decision_days),
                 x1=reset_start_date + pd.Timedelta(days=decision_days + trading_days),
                 y0=min_z, y1=max_z, fillcolor="rgba(0, 0, 255, 0.3)", line=dict(width=0))
        ]
    elif expand_trading:
        # Expand only the trading rectangle, keep the others fixed
        start_date = dates[i]
        return [
            dict(type="rect", x0=start_date, x1=start_date + pd.Timedelta(days=forming_days),
                 y0=min_z, y1=max_z, fillcolor="rgba(255, 0, 0, 0.3)", line=dict(width=0)),
            dict(type="rect", x0=start_date + pd.Timedelta(days=forming_days),
                 x1=start_date + pd.Timedelta(days=forming_days + decision_days),
                 y0=min_z, y1=max_z, fillcolor="rgba(0, 255, 0, 0.3)", line=dict(width=0)),
            dict(type="rect", x0=start_date + pd.Timedelta(days=forming_days + decision_days),
                 x1=start_date + pd.Timedelta(days=forming_days + decision_days + trading_days + j),
                 y0=min_z, y1=max_z, fillcolor="rgba(0, 0, 255, 0.3)", line=dict(width=0))
        ]
    else:
        # Normal movement of rectangles
        start_date = dates[i]
        return [
            dict(type="rect", x0=start_date, x1=start_date + pd.Timedelta(days=forming_days),
                 y0=min_z, y1=max_z, fillcolor="rgba(255, 0, 0, 0.3)", line=dict(width=0)),
            dict(type="rect", x0=start_date + pd.Timedelta(days=forming_days),
                 x1=start_date + pd.Timedelta(days=forming_days + decision_days),
                 y0=min_z, y1=max_z, fillcolor="rgba(0, 255, 0, 0.3)", line=dict(width=0)),
            dict(type="rect", x0=start_date + pd.Timedelta(days=forming_days + decision_days),
                 x1=start_date + pd.Timedelta(days=forming_days + decision_days + trading_days),
                 y0=min_z, y1=max_z, fillcolor="rgba(0, 0, 255, 0.3)", line=dict(width=0))
        ]

# Configure frames
frames = []
stabilized = False
for i in range(total_days - forming_days - decision_days - trading_days):
    current_date = dates[i]

    # Create frames with moving rectangles; Z-score line with spike remains static
    if not stabilized and dates[i + forming_days + decision_days + trading_days] >= dates[midpoint_index]:
        # Stabilize the trading rectangle for multiple frames
        last_trading_upper_bound = None
        for j in range(stabilize_frames):
            frames.append(go.Frame(
                data=[go.Scatter(x=data["Date"], y=spike_z_scores, mode="lines", name="Z-score")],
                layout=go.Layout(
                    shapes=generate_rectangles(i, dates, forming_days, decision_days, trading_days, min(z_scores), max(z_scores), expand_trading=True)
                )
            ))
            last_trading_upper_bound = dates[i + forming_days + decision_days + trading_days + j]
        # Set flag for reset and capture the reset starting position for decision
        stabilized = True
        reset_start_date = last_trading_upper_bound
    elif stabilized:
        # After stabilization, reset rectangle sizes and continue normal movement with new alignment
        frames.append(go.Frame(
            data=[go.Scatter(x=data["Date"], y=spike_z_scores, mode="lines", name="Z-score")],
            layout=go.Layout(
                shapes=generate_rectangles(i, dates, forming_days, decision_days, trading_days, min(z_scores), max(z_scores), reset=True, reset_start_date=reset_start_date)
            )
        ))
        reset_start_date += pd.Timedelta(days=1)
    else:
        # Normal movement before stabilization
        frames.append(go.Frame(
            data=[go.Scatter(x=data["Date"], y=spike_z_scores, mode="lines", name="Z-score")],
            layout=go.Layout(
                shapes=generate_rectangles(i, dates, forming_days, decision_days, trading_days, min(z_scores), max(z_scores))
            )
        ))

# Main plot configuration
fig = go.Figure(
    data=[go.Scatter(x=data["Date"], y=spike_z_scores, mode="lines", name="Z-score")],
    layout=go.Layout(
        title="Backtesting with sliding window",
        xaxis=dict(title="Date"),
        yaxis=dict(title="Z-score"),
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


import plotly.offline as pyo

# Show the plot
fig.show()



# Supondo que 'fig' seja sua figura Plotly com animação
pyo.plot(fig, auto_play=False)

# Save the plot as HTML
fig.write_html("animated_z_score_with_spike_and_stabilization6.html", auto_play=False)


from google.colab import files
files.download("animated_z_score_with_spike_and_stabilization6.html")
