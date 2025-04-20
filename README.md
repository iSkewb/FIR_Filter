# Real-Time FIR Filter in Verilog with Python Visualization

The purpose of this project is to demonstrate how hardware acceleration via RTL can outperform software filtering
for digital signal processing or financial data smoothing. 

This project takes two approaches to creating an FIR filter:
  - The first is written in Python and uses Numpy for convolution.
  - The second is a Verilog implementation for real-time FPGA processing. 

# Project Motivation
  FIR filters are crucial to digital signal processing to smooth out noise. In fields like finance and communications, low-latency filtering is essential. 
  This project compares the latency of a software FIR filter with that of a custom Verilog design that can be deployed on an FPGA. 

# Software Design

 # Hardware Design

  Normalization: Configurable based on 
  
  Waveform sample:
  ![image](https://github.com/user-attachments/assets/7096db92-32fa-4256-a14c-6b9f3444f705)


# Performance Benchmark
| Metric                    | Python (Software) | Verilog Sim (Hardware) |
|---------------------------|-------------------|------------------------|
| Avg processing time       |  
|     (1000 samples)        |
| Throughput                | 
| Latency                   |   High (batch)    |    Low (streaming)     |
