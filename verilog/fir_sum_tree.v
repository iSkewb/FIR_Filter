module fir_sum_tree #(parameter WIDTH = 32, parameter TAPS = 8) (
    input wire signed [WIDTH*TAPS-1:0] data_in_flat,
    output wire signed [WIDTH+3:0] sum_out  // WIDTH + ceil(log2(TAPS)) to prevent overflow
);
    wire signed [WIDTH-1:0] data_in [TAPS-1:0];
    wire signed [WIDTH+3:0] partial_sum [TAPS-1:0];  // Allow headroom for summed output

    genvar i;
    generate
        // Unpack the flattened input
        for (i = 0; i < TAPS; i = i + 1) begin : unpack
            assign data_in[i] = data_in_flat[WIDTH*(i+1)-1 -: WIDTH];
        end
    endgenerate

    // Add all values (brute force)
    assign sum_out = 
        data_in[0] + data_in[1] + data_in[2] + data_in[3] +
        data_in[4] + data_in[5] + data_in[6] + data_in[7];

endmodule
