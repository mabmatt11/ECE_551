module Auth_blk_tb();

logic clk,rst_n; // clock and async reset
logic rx_rdy,rider_off; // signals for UART ready and if rider is off
logic [7:0] rx_data; // data from uart
logic RX; // data received from uart

logic trmt,tx_done; // trasmission start and done
logic [7:0] tx_data; // trasmission data
logic pwr_up,clr_rx_rdy; // power up and if rx is clear

localparam G = 8'h67; // local params for bluetooth signals
localparam S = 8'h73;

// Instantiate auth block //////
Auth_blk AUTH(.clk(clk),.rst_n(rst_n),.rx_rdy(rx_rdy),.rider_off(rider_off),.rx_data(rx_data),
              .pwr_up(pwr_up),.clr_rx_rdy(clr_rx_rdy));

// Instantiate uart receiving block ////
UART_rcv REC(.clk(clk),.rst_n(rst_n),.RX(RX),.clr_rdy(clr_rx_rdy),.rx_data(rx_data),.rdy(rx_rdy));

// Instantiate uart transmission block ///
UART_tx TRAN(.clk(clk),.rst_n(rst_n),.TX(RX),.trmt(trmt),.tx_data(tx_data),.tx_done(tx_done));

/// set up clock
initial begin
  clk = 0;
  forever begin
    #5;
    clk = ~clk;
  end
end

// test
initial begin
// set up default, reset everything
rst_n = 0;
trmt = 1'b0; 
tx_data = 8'b10101010; 
rider_off = 0;

repeat(100) @(posedge clk);
rst_n = 1; // stop reset to begin test

repeat(100) @(posedge clk);

trmt = 1;
@(posedge clk); // send first transmission
trmt = 0;

repeat(28000) @(posedge clk);
if (AUTH.state != 2'h0) begin
  $display("Auth block not in correct state, debug! %h",AUTH.state);
  $stop;
end

tx_data = G; // send start up signals
trmt = 1;
@(posedge clk); // transmit
trmt = 0;

repeat(28000) @(posedge clk);
if (AUTH.state != 2'h1) begin
  $display("Auth block not in correct state, debug!");
  $stop;
end

tx_data = S; // send stop signal
rider_off = 1; // rider off power down
trmt = 1; // transmit
@(posedge clk);
trmt = 0;
repeat(28000) @(posedge clk);

if (AUTH.state != 2'h0) begin
  $display("Auth block not in correct state, debug!");
  $stop;
end

tx_data = G; // send start up signal
rider_off = 0; // rider on
trmt = 1; // transmit
@(posedge clk);
trmt = 0;
repeat(28000) @(posedge clk);
if (AUTH.state != 2'h1) begin
  $display("Auth block not in correct state, debug!");
  $stop;
end

tx_data = S; // send stop signal, rider on
trmt = 1; // transmit
@(posedge clk);
trmt = 0;
repeat(28000) @(posedge clk);
if (AUTH.state != 2'h2) begin
  $display("Auth block not in correct state, debug! %h",AUTH.state);
  $stop;
end

tx_data = G; // send start signal, rider on
trmt = 1;
@(posedge clk);
trmt = 0;
repeat(28000) @(posedge clk);
if (AUTH.state != 2'h1) begin
  $display("Auth block not in correct state, debug!");
  $stop;
end

tx_data = S; // send stop signal, rider on
trmt = 1; // transmit
@(posedge clk);
trmt = 0;
repeat(28000) @(posedge clk);
if (AUTH.state != 2'h2) begin
  $display("Auth block not in correct state, debug!");
  $stop;
end

rider_off = 1; // rider off

repeat(1000) @(posedge clk);
if (AUTH.state != 2'h0) begin
  $display("Auth block not in correct state, debug!");
  $stop;
end

$display("All auth block states correct!");
$stop;
end

endmodule

