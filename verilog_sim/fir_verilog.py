import pandas as pd
import matplotlib.pyplot as plt
import os

# Relative path to Vivado CSV output
csv_path = os.path.join("verilog_sim", "fir_data.csv")

# Load CSV
df = pd.read_csv(csv_path)

# Ignore startup and tail transients
TAPS = 12
steady_state_df = df.iloc[TAPS:-TAPS]

plt.figure(figsize=(12, 5))
plt.plot(steady_state_df['cycle'], steady_state_df['x_in'], label='Noisy Input (x_in)', color='deepskyblue', linewidth=1.5)
plt.plot(steady_state_df['cycle'], steady_state_df['y_out'], label='Filtered Output (y_out)', color='orange', linewidth=2.5)

plt.title("FIR Filter Output (Steady-State Region)")
plt.xlabel("Cycle")
plt.ylabel("Value")
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(loc='upper right')
plt.tight_layout()
plt.show()
