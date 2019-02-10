module UART_tx(clk, rst_n, TX, trmt, tx_data, tx_done);

    input clk, rst_n, trmt;
    input [7:0] tx_data;
    output TX;
    output reg tx_done;

    wire nxt_tx_done;
    wire set_done;
    wire clr_done;

    reg [11:0] baud_cnt;
    reg [3:0] bit_cnt;
    reg [8:0] tx_shift_reg;

    wire [11:0] nxt_baud_cnt;
    wire [3:0] nxt_bit_cnt;
    wire [8:0] nxt_tx_shift_reg;

    parameter LOAD = 2'b00, TRANSMIT = 2'b01, SHIFT = 2'b10;

    reg [1:0] state;
    wire [1:0] nxt_state;

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            bit_cnt <= 4'h0;
        else
            bit_cnt <= nxt_bit_cnt;

    // Count up when we are shifting, and reset when we load
    assign nxt_bit_cnt = (state == LOAD) ? 4'h0 :
                         (state == SHIFT) ? bit_cnt + 1 :
                         bit_cnt;

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            baud_cnt <= 11'h0000;
        else
            baud_cnt <= nxt_baud_cnt;

    // Count down unless we are loading or shifting
    assign nxt_baud_cnt = (state == LOAD || state == SHIFT) ? 13'd2604 :
                          baud_cnt - 1;

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            tx_shift_reg <= 9'h1FF;
        else
            tx_shift_reg <= nxt_tx_shift_reg;

    // Load tx data when we are loading, and shift data when we are shifting
    assign nxt_tx_shift_reg = (state == LOAD) ? {tx_data, 1'b0} :
                              (state == SHIFT) ? tx_shift_reg >> 1 :
                              tx_shift_reg;

    assign TX = (state == LOAD) ? 1'b1 : tx_shift_reg[0];

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            state <= 2'b00;
        else
            state <= nxt_state;

    // Make correct state transition
    assign nxt_state = (state == LOAD && trmt == 1'b1) ? TRANSMIT :         // Start transmitting when we are done loading and are told to start transmitting
                       (state == TRANSMIT && baud_cnt == 0) ? SHIFT :       // Shift after the baud counter depletes
                       (state == SHIFT && bit_cnt != 8) ? TRANSMIT :        // Begin transmitting again if there are more bits to send
                       (state == SHIFT && bit_cnt == 8) ? LOAD :            // Finish if we have sent all bits
                       state;

    // Set done when we are done shifting and moving into the load state
    assign set_done = (state == SHIFT && nxt_state == LOAD);

    // Clear done when we start to transmit again
    assign clr_done = trmt;

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            tx_done <= 1'b0;
        else
            tx_done <= nxt_tx_done;

    // Assign next done value to mimic rs flop
    assign nxt_tx_done = (set_done) ? 1'b1 :
                         (clr_done) ? 1'b0 :
                         tx_done;

endmodule

