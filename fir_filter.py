import yfinance as yf
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import datetime
import time
import numpy as np

# Choose your stock symbol
symbol = "AAPL"

# Set data fetch interval (e.g., 1m = 1 minute candles)
interval = "1m"

# FIR filter coefficients (simple moving average)
coeffs = np.array([1, 2, 3, 4, 4, 3, 2, 1])
coeffs = coeffs / np.sum(coeffs)  # Normalize

# Track recent price data
price_history = []
filtered_history = []

# Set max number of points to show on plot
MAX_POINTS = 50
FIR_TAPS = len(coeffs)

def fetch_price():
    # Get most recent candle
    ticker = yf.Ticker(symbol)
    data = ticker.history(period="5d", interval=interval)
    
    if not data.empty:
        return data['Close'].iloc[-1]
    else:
        return None

# Animation function
def update(frame):
    current_price = fetch_price()
    if current_price is not None:
        price_history.append(current_price)
        if len(price_history) > MAX_POINTS:
            price_history.pop(0)

        # Apply FIR filter if we have enough samples
        if len(price_history) >= FIR_TAPS:
            start_time = time.perf_counter()

            window = price_history[-FIR_TAPS:]
            filtered_val = np.dot(window[::-1], coeffs)  # Reverse for FIR style

            end_time = time.perf_counter()
            filter_time_us = (end_time - start_time) * 1e6  # microseconds

            filtered_history.append(filtered_val)
            if len(filtered_history) > MAX_POINTS:
                filtered_history.pop(0)

            print(f"FIR Filter Time: {filter_time_us:.2f} μs")

    # Plot
    ax.clear()
    ax.plot(price_history, label=f'{symbol} Price')
    if len(filtered_history) > 0:
        ax.plot(range(len(price_history)-len(filtered_history), len(price_history)),
                filtered_history, label='FIR Filtered', linewidth=2)
    ax.set_title(f"Real-Time {symbol} Price with FIR Filter")
    ax.set_ylabel("Price (USD)")
    ax.set_xlabel("Time (ticks)")
    ax.legend()
    ax.grid(True)

# Setup plot
fig, ax = plt.subplots()
ani = animation.FuncAnimation(fig, update, interval=60)  # Update every 60s (1m data)
plt.tight_layout()
plt.show()
