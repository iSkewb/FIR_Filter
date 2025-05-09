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
    ser.write(f"{val}\n".encode())

def read_output():
    try:
        line = ser.readline()
        print(repr(line))
        return None
        # line = ser.readline().decode().strip()
        # return int(line)
    except:
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
