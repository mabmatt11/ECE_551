module A2D_intf(clk, rst_n, lft_ld, rght_ld, batt, nxt, SS_n, SCLK, MOSI, MISO);

    input nxt, clk, rst_n, MISO; // clk, async reset, inputs for spi
    output SS_n, SCLK, MOSI; // outputs from spi
    output reg [11:0] lft_ld, rght_ld, batt; // readings for feet and battery

    wire done, wrt; // signal for when spi is finished and to start spi reading
    reg [15:0] cmd; // command to send to spi
    wire [15:0] rd_data; // data received from spi

    wire lft_ld_en, rght_ld_en, batt_en; // whether we are reading each 

    reg [1:0] robin_counter, nxt_robin_counter; // for switching which reading
	
	// state machine states
    typedef enum { START_FIRST, END_FIRST, START_SECOND, END_SECOND, SAMPLE, HOLD } Transaction;
    Transaction transaction_counter, nxt_transaction_counter;

	// parameters for channels
    localparam LEFT_CHANNEL = 16'h0000, RIGHT_CHANNEL = 16'h2000, BATTERY_CHANNEL = 16'h2800;

	// Instantiate spi
    SPI_mstr16 SPI_mstr16_inst(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO), .wrt(wrt), .cmd(cmd), .done(done), .rd_data(rd_data));

	// flop for switching channels
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            robin_counter <= 0;
        else if (nxt)
            robin_counter <= 0;
        else
            robin_counter <= nxt_robin_counter;

	// to count up the round robin_counter
    always_comb begin
        nxt_robin_counter = robin_counter;
        if (transaction_counter == SAMPLE)
            nxt_robin_counter = robin_counter + 1;
    end

	// to set which reading from robin counter
    assign lft_ld_en = robin_counter == 0 && transaction_counter == SAMPLE;
    assign rght_ld_en = robin_counter == 1 && transaction_counter == SAMPLE;
    assign batt_en = robin_counter == 2 && transaction_counter == SAMPLE;

	// commands to send based on robin counter
    always_comb begin
        case (robin_counter)
            0 : cmd = LEFT_CHANNEL;
            1 : cmd = RIGHT_CHANNEL;
            default : cmd = BATTERY_CHANNEL;
        endcase
    end

	// state machine flop
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            transaction_counter <= START_FIRST;
        else if (nxt)
            transaction_counter <= START_FIRST;
        else
            transaction_counter <= nxt_transaction_counter;

	// state machine!
    always_comb begin
        nxt_transaction_counter = transaction_counter; // default next state is the same
        case (transaction_counter) 
            START_FIRST :
                nxt_transaction_counter = END_FIRST;
            END_FIRST : begin
                if (done)
                    nxt_transaction_counter = START_SECOND;
            end
            START_SECOND :
                nxt_transaction_counter = END_SECOND;
            END_SECOND : begin
                if (done)
                    nxt_transaction_counter = SAMPLE;
            end
            SAMPLE : begin
                if (robin_counter == 2)
                    nxt_transaction_counter = HOLD;
                else
                    nxt_transaction_counter = START_FIRST;
            end
            default : begin
                nxt_transaction_counter = HOLD;
            end
        endcase
    end

	// starts spi reading based on states
    assign wrt = (transaction_counter == START_FIRST || transaction_counter == START_SECOND);

	// get left load data
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            lft_ld <= 0;
        else if (lft_ld_en)
            lft_ld <= rd_data[11:0];

	// get right load data
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            rght_ld <= 0;
        else if (rght_ld_en)
            rght_ld <= rd_data[11:0];

	// get battery data
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            batt <= 0;
        else if (batt_en)
            batt <= rd_data[11:0];

endmodule

