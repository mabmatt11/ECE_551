module UART_rcv(clk, rst_n, RX, clr_rdy, rx_data, rdy);

    input clk, rst_n, clr_rdy, RX;

    output reg [7:0] rx_data;
    output reg rdy;

    reg [12:0] baud_cnt;
    reg [3:0] bit_cnt;

    reg unstable_rx;
    reg stable_rx;

    wire [3:0] nxt_bit_cnt;
    wire [12:0] nxt_baud_cnt;
    wire [7:0] nxt_rx_data;
    wire nxt_rdy;

    parameter START = 2'b00, RECEIVING = 2'b01, SHIFT = 2'b10, SKIP = 2'b11;

    reg [1:0] state;
    wire [1:0] nxt_state;

    wire set_rdy, start;

    // Double gate the input
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            unstable_rx <= 1'b1;
        else
            unstable_rx <= RX;

    // Double gate the input
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            stable_rx <= 1'b1;
        else
            stable_rx <= unstable_rx;

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            bit_cnt <= 4'h0;
        else
            bit_cnt <= nxt_bit_cnt;

    // Increment the bitcount when shifting, reset on start, hold otherwise
    assign nxt_bit_cnt = (nxt_state == START) ? 4'h0 :
                         (nxt_state == SHIFT) ? bit_cnt + 1 :
                         bit_cnt;

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            baud_cnt <= 13'h0000;
        else
            baud_cnt <= nxt_baud_cnt;

    // Reset the baud count when starting or shifting, otherwise decrement
    assign nxt_baud_cnt = (nxt_state == START) ? 13'd1302 :
                          (nxt_state == SHIFT) ? 13'd2604 :
                          baud_cnt - 1;

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            rx_data <= 8'h00;
        else
            rx_data <= nxt_rx_data;

    // Shift in the receive line when shifting
    assign nxt_rx_data = (nxt_state == SHIFT) ? {stable_rx, rx_data[7:1]} :
                         rx_data;

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            state <= START;
        else
            state <= nxt_state;

    // Assing next correct state
    assign nxt_state = (state == START && stable_rx == 0) ? RECEIVING :     // Start receiving when a negedge is received
                       (state == RECEIVING && baud_cnt == 0) ? SHIFT :      // Shift in the receive line when the baud counter runs out
                       (state == SHIFT && bit_cnt != 9) ? RECEIVING :       // Start receiving again if there are more bits to receive
                       (state == SHIFT && bit_cnt == 9) ? SKIP :            // Skip a full baud count if the last bit has been shifted in
                       (state == SKIP && baud_cnt == 0) ? START :           // Start over when we have skipped to the middle of the stop bit
                       state;

    // Clear ready if we started receiving
    assign start = (state == START && nxt_state == RECEIVING);

    // Set ready if we have stopped receiving
    assign set_rdy = (state == SKIP && nxt_state == START);

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            rdy <= 1'b0;
        else
            rdy <= nxt_rdy;

    // Assign to ready as if it were an RS flop
    assign nxt_rdy = (start) ? 1'b0 :
                     (set_rdy) ? 1'b1 :
                     (clr_rdy) ? 1'b0 :
                     rdy;

endmodule

