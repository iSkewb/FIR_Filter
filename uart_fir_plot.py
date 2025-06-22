import serial
import time
import random
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import serial.tools.list_ports
print([port.device for port in serial.tools.list_ports.comports()])

# ========== Configuration ==========
PORT = 'COM4'  # Replace with your COM port
BAUD = 115200
NUM_POINTS = 100

# ========== Connect to Serial ==========
ser = serial.Serial(PORT, BAUD, timeout=0.5)
time.sleep(2)  # Give FPGA time to reset UART

# ========== Data Buffers ==========
x_vals = []
y_vals = []

def send_input(val):
    # Send 16-bit value as 2 bytes (MSB first, then LSB)
    msb = (val >> 8) & 0xFF
    lsb = val & 0xFF
    ser.write(bytes([msb, lsb]))

def read_output():
    try:
        # Read 2 bytes for 16-bit output (MSB first, then LSB)
        data = ser.read(2)
        if len(data) == 2:
            # Convert bytes to signed 16-bit integer
            val = (data[0] << 8) | data[1]
            # Handle sign extension for signed 16-bit
            if val >= 32768:
                val -= 65536
            return val
        return None
    except Exception as e:
        print("Read error:", e)
        return None

# ========== Plotting ==========
fig, ax = plt.subplots()
line_in, = ax.plot([], [], label='Input (x_in)')
line_out, = ax.plot([], [], label='Filtered Output (y_out)')
ax.set_ylim(9900, 10100)  # Adjust as needed
ax.set_xlim(0, NUM_POINTS)
ax.grid(True)
ax.legend()

def update(frame):
    # Simulate noisy input
    x = 10000 + random.randint(-50, 50)
    send_input(x)
    y = read_output()

    if y is not None:
        x_vals.append(x)
        y_vals.append(y)

        if len(x_vals) > NUM_POINTS:
            x_vals.pop(0)
            y_vals.pop(0)

        line_in.set_data(range(len(x_vals)), x_vals)
        line_out.set_data(range(len(y_vals)), y_vals)

    return line_in, line_out

ani = animation.FuncAnimation(fig, update, interval=50)
plt.tight_layout()
plt.show()
