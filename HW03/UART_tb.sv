module UART_tb();

reg clk,rst_n;
reg trmt,clr_rdy;
reg [7:0] tx_data;

wire transmit,tx_done,rdy;
wire [7:0] rx_data;

UART_rcv iRECEIVE(.clk(clk), .rst_n(rst_n), .clr_rdy(clr_rdy), .RX(transmit), .rx_data(rx_data), .rdy(rdy));

UART_tx iTRANSMIT(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .TX(transmit), .tx_done(tx_done));

always begin
  clk = 0;
  rst_n = 0;
  clr_rdy = 0;
  trmt = 0;
  #30;
  rst_n = 1;
  #550000;
  tx_data = 8'b00000000;
  #550000;
  trmt = 1;
  #20;
  trmt = 0;
  #550000;
  tx_data = 8'b01110110;
  #550000;
  trmt = 1;
  #20;
  trmt = 0;
  #550000;
  #550000;
  $stop;
  
  end

always
  #10 clk <= ~clk;		// toggle clock every 10 time units
  
  endmodule
