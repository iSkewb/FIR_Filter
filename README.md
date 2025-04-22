# Real-Time FIR Filter in Verilog with Python Visualization

The purpose of this project is to demonstrate how hardware acceleration via RTL can outperform software filtering for digital signal processing or financial data smoothing. 

This project takes two approaches to creating an FIR filter:
  - The first is written in Python and uses Numpy for convolution.
  - The second is a Verilog implementation for real-time FPGA processing. 

# Project Motivation
  FIR filters are crucial to digital signal processing to smooth out noise. In fields like finance and communications, low-latency filtering is essential. 
  This project compares the latency of a software FIR filter with that of a custom Verilog design that can be deployed on an FPGA. 

# Software Design

  - Uses 'numpy.convolve()' with 8-tap coefficients
  - Can generate random signals, or use real-world data from yfinance
   - **Note:** Due to limitations of yfinance, real-world data will only update every 1 minute


  Waveform sample:
  ![image](https://github.com/user-attachments/assets/ad800ac7-75a7-4f7e-a513-5846f6185034)



# Hardware Design
  - **Taps:** 8
  - **Bit width:** 16-bit input, 20-bit accumulator (4 bits of headroom)
  - **Normalization:** Configurable based on COEFF_SUM
  
  Waveform sample:
  ![image](https://github.com/user-attachments/assets/f7617947-32f4-43ab-8e5b-8bb951733d34)




# Performance Benchmark
| Metric                    | Python (Software) | Verilog Sim (Hardware) |
|---------------------------|-------------------|------------------------|
| Avg processing time(1000 samples) | 980 ns    |  10 ns
| Throughput                | 915.461k samples/sec | 100M samples/sec
| Latency                   |   High (batch)    |    Low (streaming)     |

##  How to Run

### Simulate Verilog
```bash
cd verilog/testbench
iverilog -o sim fir_filter_tb.v ../fir_filter_top.v ../fir_filter_core.v ../coeff_rom.v
vvp sim
