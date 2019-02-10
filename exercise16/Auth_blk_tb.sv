module Auth_blk_tb();

logic clk,rst_n;
logic rx_rdy,rider_off;
logic [7:0] rx_data;
logic RX;

logic trmt,tx_done;
logic [7:0] tx_data;

logic pwr_up,clr_rx_rdy;

localparam G = 8'h67;
localparam S = 8'h73;

Auth_blk AUTH(.clk(clk),.rst_n(rst_n),.rx_rdy(rx_rdy),.rider_off(rider_off),.rx_data(rx_data),
              .pwr_up(pwr_up),.clr_rx_rdy(clr_rx_rdy));

UART_rcv REC(.clk(clk),.rst_n(rst_n),.RX(RX),.clr_rdy(clr_rx_rdy),.rx_data(rx_data),.rdy(rx_rdy));

UART_tx TRAN(.clk(clk),.rst_n(rst_n),.TX(RX),.trmt(trmt),.tx_data(tx_data),.tx_done(tx_done));


initial begin
  clk = 0;
  forever begin
    #5;
    clk = ~clk;
  end
end


initial begin

rst_n = 0;
trmt = 1'b0; 
tx_data = 8'b10101010; 
rider_off = 0;

repeat(100) @(posedge clk);
rst_n = 1;

repeat(100) @(posedge clk);

trmt = 1;
@(posedge clk);
trmt = 0;

repeat(28000) @(posedge clk);

tx_data = G;
trmt = 1;
@(posedge clk);
trmt = 0;

repeat(28000) @(posedge clk);

tx_data = S;
rider_off = 1;
trmt = 1;
@(posedge clk);
trmt = 0;
repeat(28000) @(posedge clk);

tx_data = G;
rider_off = 0;
trmt = 1;
@(posedge clk);
trmt = 0;
repeat(28000) @(posedge clk);

tx_data = S;
trmt = 1;
@(posedge clk);
trmt = 0;
repeat(28000) @(posedge clk);

tx_data = G;
trmt = 1;
@(posedge clk);
trmt = 0;
repeat(28000) @(posedge clk);

tx_data = S;
trmt = 1;
@(posedge clk);
trmt = 0;
repeat(28000) @(posedge clk);

rider_off = 1;

repeat(1000) @(posedge clk);

$stop;
end

endmodule

