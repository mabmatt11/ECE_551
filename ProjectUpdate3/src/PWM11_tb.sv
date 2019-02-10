module PWM11_tb();

reg clk,rst_n; //clock and async reset
reg [10:0] duty; // for how long of each period the PWM sig should be high

wire PWM_sig; // PWM sig for wheel speed

////// INSTANTIATE DUT //////
PWM11 iDUT (.clk(clk),.rst_n(rst_n),.duty(duty),.PWM_sig(PWM_sig));

// test
initial begin
  clk = 0;
  rst_n = 1; // set defaults  
  duty = 11'h000;
  repeat(50) @(posedge clk);
  rst_n = 0; 
  duty = 11'h555; // should not see this because of reset 
  repeat(500) @(posedge clk);

  if (PWM_sig == 1) begin
    $display("PWM signal not correct.");
    $stop;
  end
  rst_n = 1;
  duty = 11'h7FF;
  repeat(2047) @(posedge clk);
  if (PWM_sig == 0) begin
    $display("PWM signal not correct.");
    $stop;
  end
  @(posedge clk);
 
  duty = 11'h000;
  
  repeat(2) @(posedge clk);
  if (PWM_sig == 1) begin
    $display("PWM signal not correct.");
    $stop;
  end
  repeat(2046) @(posedge clk);

  duty = 11'h123;
  repeat(290) @(posedge clk);
  if (PWM_sig == 0) begin
    $display("PWM signal not correct.");
    $stop;
  end
  repeat(3) @(posedge clk);
  if (PWM_sig == 1) begin
    $display("PWM signal not correct.");
    $stop;
  end
  repeat(1755) @(posedge clk);

  duty = 11'h000;
  repeat(2) @(posedge clk);
  if (PWM_sig == 1) begin
    $display("PWM signal not correct.");
    $stop;
  end
  repeat(2046) @(posedge clk);
  duty = 11'h100;
  repeat(255) @(posedge clk);
  if (PWM_sig == 0) begin
    $display("PWM signal not correct.");
    $stop;
  end 
  repeat(1793) @(posedge clk);
  duty = 11'h000;
  repeat(2046) @(posedge clk);
  if (PWM_sig == 1) begin
    $display("PWM signal not correct.");
    $stop;
  end
  repeat(2) @(posedge clk);
  duty = 11'h7FF;
  repeat(2046) @(posedge clk);
  if (PWM_sig == 0) begin
    $display("PWM signal not correct.");
    $stop;
  end
  repeat(2) @(posedge clk);
  duty = 11'h333;
  repeat(819) @(posedge clk);
  if (PWM_sig == 0) begin
    $display("PWM signal not correct.");
    $stop;
  end
  repeat(2) @(posedge clk);
  if (PWM_sig == 1) begin
    $display("PWM signal not correct.");
    $stop;
  end
  repeat(1227) @(posedge clk);
  duty = 11'h7FF;
  repeat(2047) @(posedge clk);
  if (PWM_sig == 0) begin
    $display("PWM signal not correct.");
    $stop;
  end
  @(posedge clk);
  duty = 11'h3FF;
  repeat(2048) @(posedge clk);
  duty = 11'h3FF;

  $display("Duty is correct, PWM passed.");
  $stop;
  end

  //set up clock
always
  #5	
  #5 clk = ~clk;


endmodule
