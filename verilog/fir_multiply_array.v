module fir_multiply_array #(parameter WIDTH = 16, parameter TAPS = 8) (
    input wire signed [TAPS*WIDTH-1:0] taps_flat,
    input wire signed [TAPS*WIDTH-1:0] coeffs_flat,
    output wire signed [TAPS*2*WIDTH-1:0] products_flat
);
    // Internal unpacked arrays for ease of manipulation
    wire signed [WIDTH-1:0] taps     [TAPS-1:0];
    wire signed [WIDTH-1:0] coeffs   [TAPS-1:0];
    wire signed [2*WIDTH-1:0] products [TAPS-1:0];

    genvar i;

    // Slice inputs into arrays
    generate
        for (i = 0; i < TAPS; i = i + 1) begin : slice_inputs
            assign taps[i]   = taps_flat[WIDTH*(i+1)-1 -: WIDTH];
            assign coeffs[i] = coeffs_flat[WIDTH*(i+1)-1 -: WIDTH];
        end
    endgenerate

    // Perform multiplication
    generate
        for (i = 0; i < TAPS; i = i + 1) begin : multiply_loop
            assign products[i] = taps[i] * coeffs[i];
        end
    endgenerate

    // Flatten products to output
    generate
        for (i = 0; i < TAPS; i = i + 1) begin : flatten_output
            assign products_flat[2*WIDTH*(i+1)-1 -: 2*WIDTH] = products[i];
        end
    endgenerate

endmodule
