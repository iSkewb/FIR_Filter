module shift_register_8 #(parameter WIDTH = 16) (
    input wire clk,
    input wire rst,
    input wire [WIDTH-1:0] data_in,
    output wire [WIDTH*8-1:0] taps_flat // taps[0] is newest, taps[7] is oldest
);
    reg [WIDTH-1:0] taps [7:0];  // Internal array
    integer i;

    // Shift logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1)
                taps[i] <= 0;
        end else begin
            for (i = 7; i > 0; i = i - 1)
                taps[i] <= taps[i-1];
            taps[0] <= data_in;
        end
    end

    // Flatten taps[] into taps_flat output
    genvar j;
    generate
        for (j = 0; j < 8; j = j + 1) begin : flatten_loop
            assign taps_flat[WIDTH*(j+1)-1 -: WIDTH] = taps[j];
        end
    endgenerate

endmodule
