module PWM11_tb();

reg clk,rst_n; //Clock and async reset for flops
reg [10:0] duty; //Duty signal to determine PWM strength

wire PWM_sig; //Output PWM

// Instantiate the DUT
PWM11 iDUT (.clk(clk),.rst_n(rst_n),.duty(duty),.PWM_sig(PWM_sig));

initial begin
  rst_n = 0; clk = 0; //Initialize clock and async reset
  #10240;
  rst_n = 1; //deassert async reset to allow testing
  #20480;
  duty = 11'h7FF; //PWM should be full period (except for last  count)
  #20480;
  duty = 11'h000; //PWM should be full 0
  #20480;
  duty = 11'h123; //PWM should be high for a little bit then drop
  #20480;

  $stop;
  end

  //Create clock for flops
always 
  #5 clk = ~clk;


endmodule
