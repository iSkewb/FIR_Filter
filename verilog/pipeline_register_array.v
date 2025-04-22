module pipeline_register_array #(parameter WIDTH = 32, parameter STAGES = 8) (
    input wire clk,
    input wire rst,
    input wire signed [WIDTH*STAGES-1:0] data_in_flat,
    output reg signed [WIDTH*STAGES-1:0] data_out_flat
);
    reg signed [WIDTH-1:0] stage_regs [STAGES-1:0];
    integer i;

    // Flattened input to internal array
    wire signed [WIDTH-1:0] input_array [STAGES-1:0];
    genvar j;
    generate
        for (j = 0; j < STAGES; j = j + 1) begin : unpack_input
            assign input_array[j] = data_in_flat[WIDTH*(j+1)-1 -: WIDTH];
        end
    endgenerate

    // Register stage
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < STAGES; i = i + 1)
                stage_regs[i] <= 0;
        end else begin
            for (i = 0; i < STAGES; i = i + 1)
                stage_regs[i] <= input_array[i];
        end
    end

    // Flatten output
    generate
        for (j = 0; j < STAGES; j = j + 1) begin : flatten_output
            always @(*) begin
                data_out_flat[WIDTH*(j+1)-1 -: WIDTH] = stage_regs[j];
            end
        end
    endgenerate

endmodule
