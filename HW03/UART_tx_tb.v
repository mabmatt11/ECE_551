module UART_tx_tb();

reg clk,rst_n,trmt;
reg tx_data [7:0];

wire TX,tx_done;

always begin
  clk = 0;
  rst_n = 1;
  #70000;
  tx_data = 8'b00000000;
  #35000;
  trmt = 1;
  #20;
  trmt = 0;
  #70000;
  tx_data = 8'b01110110;
  #20000;
  trmt = 1;
  #20;
  trmt = 0;
  #70000;

always
  #10 clk <= ~clk;		// toggle clock every 10 time units
