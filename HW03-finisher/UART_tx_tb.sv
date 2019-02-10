module UART_tx_tb();

reg clk,rst_n,trmt;
reg [7:0] tx_data;

wire TX,tx_done;

UART_tx iDUT(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .TX(TX), .tx_done(tx_done));

always begin
  clk = 0;
  rst_n = 0;
  tx_data = 8'b00000000;
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
  tx_data = 8'b10101010;
  #550000;
  trmt = 1;
  #20;
  trmt = 0;
  #550000;
  $stop;
  
  end

always
  #10 clk <= ~clk;		// toggle clock every 10 time units
  
  endmodule
