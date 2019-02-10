module Segway_tb();
			
//// Interconnects to DUT/support defined as type wire /////
wire SS_n,SCLK,MOSI,MISO,INT;				// to inertial sensor
wire A2D_SS_n,A2D_SCLK,A2D_MOSI,A2D_MISO, A2D_rdy;	// to A2D converter
wire [15:0] A2D_cmd;
wire RX_TX;
wire PWM_rev_rght, PWM_frwrd_rght, PWM_rev_lft, PWM_frwrd_lft;
wire piezo,piezo_n;

////// Stimulus is declared as type reg ///////
reg clk, RST_n;
reg [7:0] cmd;					// command host is sending to DUT
reg send_cmd;					// asserted to initiate sending of command
reg signed [15:0] rider_lean;	// forward/backward lean (goes to SegwayModel)
// Perhaps more needed?


/////// declare any internal signals needed at this level //////
wire cmd_sent;
// Perhaps more needed?

localparam LEFT_CHANNEL = 16'h0000, RIGHT_CHANNEL = 16'h2000, BATTERY_CHANNEL = 16'h2800;

reg [11:0] lft_ld, rght_ld, batt;
wire [15:0] nxt_lft_ld, nxt_rght_ld, nxt_batt;

reg [15:0] A2D_data, channel_data;
wire [15:0] nxt_A2D_data;

always_ff @(posedge clk, negedge RST_n)
    if (!RST_n)
        A2D_data <= 0;
    else
        A2D_data <= nxt_A2D_data;

always_comb begin
    case (A2D_cmd)
        LEFT_CHANNEL : channel_data = nxt_lft_ld;
        RIGHT_CHANNEL : channel_data = nxt_rght_ld;
        BATTERY_CHANNEL : channel_data = nxt_batt;
        default : channel_data = 16'hXXXX;
    endcase
end

assign nxt_A2D_data = (A2D_rdy) ? (channel_data) : A2D_data;

assign nxt_lft_ld = {4'b0000, lft_ld};
assign nxt_rght_ld = {4'b0000, rght_ld};
assign nxt_batt = {4'b0000, batt};

////////////////////////////////////////////////////////////////
// Instantiate Physical Model of Segway with Inertial sensor //
//////////////////////////////////////////////////////////////	
SegwayModel iPHYS(.clk(clk),.RST_n(RST_n),.SS_n(SS_n),.SCLK(SCLK),
                  .MISO(MISO),.MOSI(MOSI),.INT(INT),.PWM_rev_rght(PWM_rev_rght),
				  .PWM_frwrd_rght(PWM_frwrd_rght),.PWM_rev_lft(PWM_rev_lft),
				  .PWM_frwrd_lft(PWM_frwrd_lft),.rider_lean(rider_lean));				  

/////////////////////////////////////////////////////////
// Instantiate Model of A2D for load cell and battery //
///////////////////////////////////////////////////////
SPI_ADC128S spi_a2d128_inst(.clk(clk), .rst_n(RST_n), .SS_n(A2D_SS_n), .SCLK(A2D_SCLK), .MISO(A2D_MISO), .MOSI(A2D_MOSI), .A2D_data(A2D_data), .cmd(A2D_cmd), .rdy(A2D_rdy));
  
////// Instantiate DUT ////////
Segway iDUT(.clk(clk),.RST_n(RST_n),.LED(),.INERT_SS_n(SS_n),.INERT_MOSI(MOSI),
            .INERT_SCLK(SCLK),.INERT_MISO(MISO),.A2D_SS_n(A2D_SS_n),
			.A2D_MOSI(A2D_MOSI),.A2D_SCLK(A2D_SCLK),.A2D_MISO(A2D_MISO),
			.INT(INT),.PWM_rev_rght(PWM_rev_rght),.PWM_frwrd_rght(PWM_frwrd_rght),
			.PWM_rev_lft(PWM_rev_lft),.PWM_frwrd_lft(PWM_frwrd_lft),
			.piezo_n(piezo_n),.piezo(piezo),.RX(RX_TX));


	
//// Instantiate UART_tx (mimics command from BLE module) //////
//// You need something to send the 'g' for go ////////////////
UART_tx iTX(.clk(clk),.rst_n(RST_n),.TX(RX_TX),.trmt(send_cmd),.tx_data(cmd),.tx_done(cmd_sent));

wire [11:0] idut_lft_ld, idut_rght_ld, idut_batt;
wire idut_rst_n;
wire [3:0] idut_state;
assign idut_state = iDUT.inert_intf_inst.state;
wire [11:0] idut_pwr_up;

assign idut_lft_ld = iDUT.lft_ld;
assign idut_rght_ld = iDUT.rght_ld;
assign idut_batt = iDUT.batt;
assign idut_rst_n = iDUT.rst_n;
assign idut_pwr_up = iDUT.pwr_up;

initial begin
    clk = 0;
    RST_n = 0;
    cmd = 0;
    send_cmd = 0;
    rider_lean = 0;
    lft_ld = 12'h7FF;
    rght_ld = 12'h7F1;
    batt = 12'hFFF;
    repeat (10) @(negedge clk);
    @(negedge clk) RST_n = 1;
    repeat (10) @(negedge clk);

    repeat (8000) @(negedge clk);
    cmd = 8'h67;
    send_cmd = 1;
    @(negedge clk) send_cmd = 0;
 
    repeat(100000) @(posedge clk);

    rider_lean = 16'h1FFF;

    repeat(1000000) @(posedge clk);

    rider_lean = 16'h0000;

    repeat(1000000) @(posedge clk);
  
    $display("YAHOO! test passed!");
  
    $stop();
end

always
  #5 clk = ~clk;

endmodule	
