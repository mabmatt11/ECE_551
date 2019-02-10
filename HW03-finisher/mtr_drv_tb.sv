module mtr_drv_tb();

reg clk,rst_n,lft_rev,rght_rev; //Signals from mtr_drv. Clock and async reset for flops
				//lft_rev, rght_rev for wheel direction

reg [10:0] lft_spd,rght_spd;	//Duty cycle for both wheels

wire PWM_frwrd_lft,PWM_rev_lft,PWM_frwrd_rght,PWM_rev_rght; //Outputs for PWM for each wheel

//Instantiate the DUT
mtr_drv iDUT(.clk(clk),.rst_n(rst_n),.lft_rev(lft_rev),.rght_rev(rght_rev),.lft_spd(lft_spd),.rght_spd(rght_spd),
	     .PWM_frwrd_lft(PWM_frwrd_lft),.PWM_rev_lft(PWM_rev_lft),.PWM_frwrd_rght(PWM_frwrd_rght),.PWM_rev_rght(PWM_rev_rght));

initial begin
  rst_n = 0; clk = 0; lft_rev = 0; rght_rev = 0; //Initialize clk, async rst, and wheel direction
  lft_spd = 11'h000; //set initial wheel speeds
  rght_spd = 11'h000;
  #10240;
  rst_n = 1; //deassert async reset to allow testing
  #20480;
  lft_spd = 11'h7FF; //both left and right wheel PWM should but high full period
  rght_spd = 11'h7FF;
  #20480;
  lft_spd = 11'h000; //Both left and right wheel PWM should be low the full period
  rght_spd = 11'h000;
  #20480;
  lft_spd = 11'h123; //Both left and right wheel PWM should be high briefly
  rght_spd = 11'h123;
  #20480;
  lft_rev = 1; //Set left wheel reverse
  lft_spd = 11'h445; //Left wheel should reverse for halfish period, right should be forward briefly
  #20480;
  rght_rev = 1; //Set right wheel reverse
  lft_spd = 11'h000; //left wheel should be low the full period
  rght_spd = 11'h445; //Right wheel should reverse for halfish period.
  #20480;
  #20480;
  lft_rev = 0; //left wheel forward
  lft_spd = 11'h555; //left speed medium period
  #20480;
  #20480;

  $stop;
  end

always 
  #5 clk = ~clk;


endmodule
