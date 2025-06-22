module fir_filter_top #(
    parameter WIDTH = 16,
    parameter TAPS = 8, 
    parameter COEFF_SUM = 20
) (
    input wire clk,
    input wire rst,
    input wire signed [WIDTH-1:0] x_in,
    output wire signed [WIDTH+3:0] y_out_raw,
    output wire signed [WIDTH+3:0] y_out  // Final filtered output (w/ headroom)
);

    // Flattened wires for intermediate stages
    wire signed [WIDTH*8-1:0] taps_flat;
    wire signed [WIDTH*8-1:0] coeffs_flat;
    wire signed [2*WIDTH*8-1:0] products_flat;
    wire signed [2*WIDTH*8-1:0] products_pipeline_out;

    // ===== 1. Shift Register (stores previous 8 samples) =====
    shift_register_8 #(.WIDTH(WIDTH)) shift_reg_inst (
        .clk(clk),
        .rst(rst),
        .data_in(x_in),
        .taps_flat(taps_flat)
    );

    // ===== 2. Coefficients =====
    // You can change these values to suit your filter needs
    assign coeffs_flat = {
        16'd1, 16'd2, 16'd3, 16'd4, 16'd4, 16'd3, 16'd2, 16'd1
    }; // taps[0] � coeff[0], ..., taps[7] � coeff[7]

    // ===== 3. Multiplier Array =====
    fir_multiply_array #(.WIDTH(WIDTH), .TAPS(TAPS)) mults_inst (
        .taps_flat(taps_flat),
        .coeffs_flat(coeffs_flat),
        .products_flat(products_flat)
    );

    // ===== 4. Pipeline Register Array =====
    pipeline_register_array #(.WIDTH(2*WIDTH), .STAGES(8)) pipe_regs_inst (
        .clk(clk),
        .rst(rst),
        .data_in_flat(products_flat),
        .data_out_flat(products_pipeline_out)
    );

    // ===== 5. Pipelined Adder Tree =====
    fir_sum_tree_pipelined #(.WIDTH(2*WIDTH)) sum_tree_inst (
        .clk(clk),
        .rst(rst),
        .data_in_flat(products_pipeline_out),
        .sum_out(y_out_raw)
    );
    
    // Normalize output
    assign y_out = y_out_raw / COEFF_SUM;

endmodule
