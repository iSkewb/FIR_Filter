module fir_sum_tree_pipelined #(parameter WIDTH = 32) (
    input wire clk,
    input wire rst,
    input wire signed [WIDTH*8-1:0] data_in_flat,
    output reg signed [WIDTH+3:0] sum_out
);
    // Step 1: Unpack flattened input
    wire signed [WIDTH-1:0] data_in [7:0];
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : unpack
            assign data_in[i] = data_in_flat[WIDTH*(i+1)-1 -: WIDTH];
        end
    endgenerate

    // Step 2: Stage 1 - 4 parallel additions
    reg signed [WIDTH:0] stage1 [3:0];  // WIDTH+1 for headroom
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            stage1[0] <= 0; stage1[1] <= 0;
            stage1[2] <= 0; stage1[3] <= 0;
        end else begin
            stage1[0] <= data_in[0] + data_in[1];
            stage1[1] <= data_in[2] + data_in[3];
            stage1[2] <= data_in[4] + data_in[5];
            stage1[3] <= data_in[6] + data_in[7];
        end
    end

    // Step 3: Stage 2 - 2 additions
    reg signed [WIDTH+1:0] stage2 [1:0];
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            stage2[0] <= 0; stage2[1] <= 0;
        end else begin
            stage2[0] <= stage1[0] + stage1[1];
            stage2[1] <= stage1[2] + stage1[3];
        end
    end

    // Step 4: Stage 3 - final addition
    always @(posedge clk or posedge rst) begin
        if (rst)
            sum_out <= 0;
        else
            sum_out <= stage2[0] + stage2[1];
    end

endmodule
