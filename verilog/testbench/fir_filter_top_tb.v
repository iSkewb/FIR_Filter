`timescale 1ns / 1ps

module fir_filter_top_tb;

    parameter WIDTH = 16;
    parameter CLOCK_PERIOD_NS = 10;
    parameter NUM_SAMPLES = 100;

    // Inputs
    reg clk;
    reg rst;
    reg signed [WIDTH-1:0] x_in;

    // Outputs
    wire signed [WIDTH+3:0] y_out_raw;
    wire signed [WIDTH+3:0] y_out;

    // DUT
    fir_filter_top #(.WIDTH(WIDTH)) dut (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .y_out_raw(y_out_raw),
        .y_out(y_out)
    );

    // Clock generator: 10ns period = 100 MHz
    always #5 clk = ~clk;

    // Test data (you can simulate larger financial dataset here)
    reg signed [WIDTH-1:0] price_data [0:NUM_SAMPLES-1];
    integer i;
    initial begin
        for (i = 0; i < NUM_SAMPLES; i = i + 1) begin
            price_data[i] = 10000 + $urandom_range(-50, 50);
        end
    end

    // CSV export
    integer file, cycle;
    initial begin
        file = $fopen("fir_data.csv", "w");
        $fwrite(file, "cycle,x_in,y_out\n");
        cycle = 0;
    end

    always @(posedge clk) begin
        if (!rst) begin
            $fwrite(file, "%0d,%0d,%0d\n", cycle, x_in, y_out);
            cycle = cycle + 1;
        end
    end

    // Benchmarking Variables
    integer start_cycle, end_cycle;

    // Stimulus + timing measurement
    integer j;
    initial begin
        clk = 0;
        rst = 1;
        x_in = 0;
        #20;
        rst = 0;

        start_cycle = cycle;

        // Feed in NUM_SAMPLES
        for (j = 0; j < NUM_SAMPLES; j = j + 1) begin
            x_in = price_data[j];
            #10;
        end

        end_cycle = cycle;

        // Final hold
        repeat (10) begin
            x_in = 0;
            #10;
        end

        // Calculate and display performance results
        $display("---------- FIR Filter Benchmark ----------");
        $display("Total Samples Processed: %0d", NUM_SAMPLES);
        $display("Clock Period: %0d ns", CLOCK_PERIOD_NS);
        $display("Start Cycle: %0d", start_cycle);
        $display("End Cycle:   %0d", end_cycle);
        $display("Total Cycles: %0d", end_cycle - start_cycle);
        $display("Total Processing Time: %0d ns", (end_cycle - start_cycle) * CLOCK_PERIOD_NS);
        $display("Average Time per Sample: %.2f ns", ((end_cycle - start_cycle) * 1.0 * CLOCK_PERIOD_NS) / NUM_SAMPLES);
        $display("------------------------------------------");

        $fclose(file);
        $finish;
    end

endmodule
