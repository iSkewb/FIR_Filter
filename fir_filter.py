import numpy as np
import matplotlib.pyplot as plt
import time

# === Configuration ===
NUM_SAMPLES = 100
BASE_PRICE = 100.00
NOISE_RANGE = 0.50
TAPS = 12  # For plotting steady-state
np.random.seed(0)

# FIR filter coefficients
coeffs = np.array([1, 2, 3, 4, 4, 3, 2, 1])
coeffs = coeffs / np.sum(coeffs)
FIR_TAPS = len(coeffs)

# Generate noisy price data (simulated like Verilog)
price_data = BASE_PRICE + np.random.randint(-50, 51, size=NUM_SAMPLES) / 100.0

# Apply FIR filter
filtered_data = []
filter_times = []

for i in range(FIR_TAPS - 1, NUM_SAMPLES):
    window = price_data[i - FIR_TAPS + 1: i + 1][::-1]

    start_time = time.perf_counter()
    filtered_val = np.dot(window, coeffs)
    end_time = time.perf_counter()

    filter_time_us = (end_time - start_time) * 1e6
    filter_times.append(filter_time_us)
    filtered_data.append(filtered_val)

# === Average FIR processing time ===
avg_time_us = np.mean(filter_times)
print(f"\nAverage FIR Filter Processing Time over {len(filter_times)} samples: {avg_time_us:.2f} μs")

# === Throughput calculation ===
throughput = 1_000_000 / avg_time_us  # samples per second
print(f"Throughput: {throughput:.2f} samples/sec")

# === Plot styled like Verilog version ===
cycles = np.arange(NUM_SAMPLES)
filtered_cycles = cycles[FIR_TAPS - 1:]

# Trim for steady-state region
steady_start = TAPS
steady_end = NUM_SAMPLES - TAPS

plt.figure(figsize=(12, 5))
plt.plot(cycles[steady_start:steady_end], price_data[steady_start:steady_end],
         label='Noisy Input (x_in)', color='deepskyblue', linewidth=1.5)
plt.plot(filtered_cycles[steady_start - (FIR_TAPS - 1):steady_end - (FIR_TAPS - 1)],
         filtered_data[steady_start - (FIR_TAPS - 1):steady_end - (FIR_TAPS - 1)],
         label='Filtered Output (y_out)', color='orange', linewidth=2.5)

plt.title("FIR Filter Output (Steady-State Region)")
plt.xlabel("Cycle")
plt.ylabel("Value")
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(loc='upper right')
plt.tight_layout()
plt.show()
