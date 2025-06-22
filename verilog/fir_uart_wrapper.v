module fir_uart_wrapper #(parameter WIDTH = 16) (
    input wire clk,
    input wire rstn,
    input wire rx,         // From PC
    output wire tx         // To PC
);

    // rx signals
    wire uart_data_ready;
    wire [7:0] uart_data_byte;

    // tx signals
    reg uart_tx_start;
    reg [7:0] uart_tx_data;
    wire uart_tx_ready;

    uart_rx #( .BAUDRATE(`B115200) ) uart_rx_inst (
        .clk(clk),
        .rstn(rstn),
        .rx(rx),
        .rcv(uart_data_ready),
        .data(uart_data_byte)
    );

    uart_tx #( .BAUDRATE(`B115200) ) uart_tx_inst (
        .clk(clk),
        .rstn(rstn),
        .start(uart_tx_start),
        .data(uart_tx_data),
        .tx(tx),
        .ready(uart_tx_ready)
    );

    reg [15:0] x_in;
    reg byte_toggle;
    reg new_sample_ready;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            x_in <= 0;
            byte_toggle <= 0;
            new_sample_ready <= 0;
        end else if (uart_data_ready) begin
            if (!byte_toggle) begin
                x_in[15:8] <= uart_data_byte;
                byte_toggle <= 1;
                new_sample_ready <= 0;
            end else begin
                x_in[7:0] <= uart_data_byte;
                byte_toggle <= 0;
                new_sample_ready <= 1;
            end
        end else begin
            new_sample_ready <= 0;
        end
    end

    wire signed [WIDTH+3:0] y_out;

    // FIR Filter top level
    fir_filter_top #(
        .WIDTH(WIDTH),
        .TAPS(8),
        .COEFF_SUM(20)
    ) fir_inst (
        .clk(clk),
        .rst(~rstn),
        .x_in(x_in),
        .y_out_raw(),
        .y_out(y_out)
    );

    // send y_out to PC from MSB to LSB
    reg [1:0] tx_state;
    reg [15:0] y_out_reg;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            uart_tx_start <= 0;
            uart_tx_data <= 0;
            tx_state <= 0;
        end else begin
            uart_tx_start <= 0;
            case (tx_state) 
                0: begin
                    if (new_sample_ready && uart_tx_ready) begin
                        y_out_reg <= y_out;
                        uart_tx_data <= y_out[15:8];
                        uart_tx_start <= 1;
                        tx_state <= 1;
                    end
                end
                1: begin
                    if (uart_tx_ready) begin
                        uart_tx_data <= y_out_reg[7:0];
                        uart_tx_start <= 1;
                        tx_state <= 0;
                    end
                end
            endcase
        end
    end

endmodule