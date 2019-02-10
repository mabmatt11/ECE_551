module PWM11_tb();

reg clk,rst_n;
reg [10:0] duty;

wire PWM_sig;

PWM11 iDUT (.clk(clk),.rst_n(rst_n),.duty(duty),.PWM_sig(PWM_sig));

initial begin
  clk = 0;
  rst_n = 1;  
  duty = 11'h3FF;
  #204;
  rst_n = 0; 
  duty = 11'h555;
  #204;
  rst_n = 1;
  duty = 11'h7FF;
  #40960;
  duty = 11'h000;
  #40960;
  duty = 11'h123;
  #40960;
  duty = 11'h000;
  #40960;
  duty = 11'h900;
  #40960;
  duty = 11'h000;
  #40960;
  duty = 11'h7FF;
  #40960;
  duty = 11'h333;
  #40960;
  duty = 11'h7FF;
  #40960;
  duty = 11'h3FF;
  #40960;
  duty = 11'h3FF;



  $stop;
  end

always
  #5	
  #5 clk = ~clk;


endmodule
