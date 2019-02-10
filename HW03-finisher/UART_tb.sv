module UART_tb();

reg clk,rst_n; //clock and async reset for flops
reg trmt,clr_rdy; //input signals for sending data
reg [7:0] tx_data; //input data to send

wire transmit,tx_done,rdy; //transmit is internal signal to transmit data from tx to rcv
						   //tx_done, rdy are output signals
wire [7:0] rx_data; //output signal that should have tx_data at the end

//Instantiate the receiving DUT
UART_rcv iRECEIVE(.clk(clk), .rst_n(rst_n), .clr_rdy(clr_rdy), .RX(transmit), .rx_data(rx_data), .rdy(rdy));

//Instantiate the transmitting DUT
UART_tx iTRANSMIT(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .TX(transmit), .tx_done(tx_done));

always begin
  clk = 0; //Initialize clock
  rst_n = 0; //Initialize async reset
  clr_rdy = 0; //initialize input signals
  trmt = 0;
  #30;
  rst_n = 1; //Deassert async reset
  #550000;
  tx_data = 8'b00000000; //Give data to transmit
  #550000;
  trmt = 1; //Start transmitting
  #20;
  trmt = 0; //deassert after one clock cycle
  #550000;
  tx_data = 8'b01110110; //Give data to transmit
  #550000;
  trmt = 1; //start transmitting
  #20;
  trmt = 0; //deassert after one clock cycle
  tx_data = 8'b10101010; //give new data to transmit
  #550000;
  #550000;
  trmt = 1; //start transmitting
  #20;
  trmt = 0; //deassert after one clock cycle
  #550000;
  tx_data = 8'b11001010; //new data to transmit
  #550000;
  trmt = 1; //start transmitting
  #20;
  trmt = 0; //deassert after one clock cycle
  #550000;
  
  $stop;
  
  end

always
  #10 clk <= ~clk;		// toggle clock every 10 time units
  
  endmodule
