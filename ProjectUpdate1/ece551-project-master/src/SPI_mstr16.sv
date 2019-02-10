module SPI_mstr16(clk, rst_n, SS_n, SCLK, MOSI, MISO, wrt, cmd, done, rd_data);

    input clk, rst_n, MISO, wrt;
    input [15:0] cmd;
    output SCLK, MOSI;
    output reg SS_n, done;
    output [15:0] rd_data;

    reg [4:0] sclk_div, nxt_sclk_div;
    wire SCLK_neg, SCLK_pos;
    wire rst_cnt;

    reg [4:0] bit_cnt, nxt_bit_cnt;

    reg MISO_smpl, nxt_MISO_smpl;

    reg [15:0] shft_reg, nxt_shft_reg;

    wire set_done, clr_done;
    reg nxt_SS_n, nxt_done;

    // sclk_div flip flop
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            sclk_div <= 5'b10111;
       else
            sclk_div <= nxt_sclk_div;

    always_comb begin
        // If resetting, reset to front porch value
        if (rst_cnt)
            nxt_sclk_div = 5'b10111;
        // Otherwise increment
        else
            nxt_sclk_div = sclk_div + 1;
    end

    // Put SCLK as MSB of counter
    assign SCLK = sclk_div[4];

    // Assign SCLK_neg and SCLK_pos to expected clock edge values
    assign SCLK_neg = (sclk_div == 5'b11111);
    assign SCLK_pos = (sclk_div == 5'b01111);

    // Reset our count when we are not transmitting
    assign rst_cnt = SS_n;

    // bit_cnt flip flop
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            bit_cnt <= 0;
        else
            bit_cnt <= nxt_bit_cnt;

    always_comb begin
        // If beginning to transmit, reset bit count
        if (wrt)
            nxt_bit_cnt = 0;
        // Else if we are sampling MISO, increment bit count
        else if (SCLK_neg)
            nxt_bit_cnt = bit_cnt + 1;
        // Otherwise hold
        else
            nxt_bit_cnt = bit_cnt;
    end

    // MISO_smpl flip flop
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            MISO_smpl <= 0;
        else
            MISO_smpl <= nxt_MISO_smpl;

    always_comb begin
        // If there will be a positive SCLK edge, sample MISO
        if (SCLK_pos)
            nxt_MISO_smpl = MISO;
        // Otherwise hold
        else
            nxt_MISO_smpl = MISO_smpl;
    end

    // shft_reg flip flop
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            shft_reg <= 0;
        else
            shft_reg <= nxt_shft_reg;

    always_comb begin
        // If beginning to transmit, load in cmd to our shift register
        if (wrt)
            nxt_shft_reg = cmd;
        // Shift on negative SCLK edges except at the front porch
        else if (SCLK_neg && bit_cnt != 5'b00000)
            nxt_shft_reg = {shft_reg[14:0], MISO_smpl};
        // Otherwise hold
        else
            nxt_shft_reg = shft_reg;
    end

    // Assign MOSI to MSB of our shift register
    assign MOSI = shft_reg[15];

    // Assign our read data to our shift register
    assign rd_data = shft_reg;

    // done flip flop
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            done <= 0;      // Reset done
        else
            done <= nxt_done;

    // SS_n flip flop
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            SS_n <= 1;      // Preset SS_n
        else
            SS_n <= nxt_SS_n;

    // Set done when we have shifted 16 bits and we are about to encounter
    // a negative SCLK edge
    assign set_done = (bit_cnt == 5'b10000 && SCLK_neg);

    // Clear done when we are about to transmit again
    assign clr_done = wrt;

    always_comb begin
        // If we should set to done
        if (set_done) begin
            nxt_done = 1;
            nxt_SS_n = 1;
        // Else if we should clear done
        end else if (clr_done) begin
            nxt_done = 0;
            nxt_SS_n = 0;
        // Otherwise hold
        end else begin
            nxt_done = done;
            nxt_SS_n = SS_n;
        end
    end

endmodule

