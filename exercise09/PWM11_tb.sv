module PWM11_tb();

reg clk,rst_n;
reg [10:0] duty;

wire PWM_sig;

PWM11 iDUT (.clk(clk),.rst_n(rst_n),.duty(duty),.PWM_sig(PWM_sig));

initial begin
  rst_n = 0; clk = 0;
  #10240;
  rst_n = 1;
  #10240;
  duty = 11'h7FF;
  #10240;
  duty = 11'h000;
  #10240;
  duty = 11'h123;
  #10240;

  $stop;
  end

always 
  #5 clk = ~clk;


endmodule