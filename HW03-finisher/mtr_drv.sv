module mtr_drv(clk,rst_n,lft_spd,lft_rev,rght_spd,rght_rev,PWM_frwrd_lft,PWM_rev_lft,PWM_rev_rght,PWM_frwrd_rght);

input clk, rst_n, rght_rev, lft_rev; //clock and async reset for flops
				     //rght_rev and lft_rev when asserted will
				     //cause wheel to go reverse

input [10:0] rght_spd, lft_spd;	//The speed of the left and right wheel, determines PWM

output reg PWM_rev_lft,PWM_rev_rght,PWM_frwrd_rght,PWM_frwrd_lft; //The PWM for each wheel
							//Each wheel has
							//a forward
							//and reverse signal
							//Only one for each
							//wheel is asserted at
							//a time.

reg set_lf,reset_lf,set_rt,reset_rt; //Internal signals for maintaining PWM signals
reg [10:0] cnt;	//Counter used to manage PWM

//////////INFER COUNTER////////////////////
always_ff @(posedge clk or negedge rst_n)
  if (!rst_n)
    cnt <= 11'h000;
  else    
    cnt <= cnt + 1;

////////////Infer combinational logic for left wheel//////
always_comb
  if (cnt >= lft_spd) begin //When spd is less than cnt reset PWM sig
    reset_lf = 1;
    set_lf = 0;
  end
  else if (~|cnt) begin //When count is zero and spd is non zero set PWM high
    set_lf = 1;
    reset_lf = 0;
  end
  else begin //Maintain PWM at what it's at when count doesn't change and count is below spd
    reset_lf = 0;
    set_lf = 0;
  end

  //INFER FLOP FOR LEFT WHEEL//
always_ff @(posedge clk or negedge rst_n)
  if (!rst_n) begin //Async reset sets to 0
    PWM_rev_lft <= 1'b0;
    PWM_frwrd_lft <= 1'b0;
  end
  else if (reset_lf) begin //spd is below count, set to 0
    PWM_rev_lft <= 1'b0;
    PWM_frwrd_lft <= 1'b0;
  end
  else if (set_lf && lft_rev) //spd is above count, in reverse, set lft_rev PWM
    PWM_rev_lft <= 1'b1;
  else if (set_lf && ~lft_rev) //spd is above count, not reverse, set lft_frwrd PWM
    PWM_frwrd_lft <= 1'b1;
  else begin //Maintain flop when no changes
    PWM_frwrd_lft <= PWM_frwrd_lft;
    PWM_rev_lft <= PWM_rev_lft;
  end

  //INFER COMBINATIONAL LOGIC FOR RIGHT WHEEL//
always_comb
  if (cnt >= rght_spd) begin //When spd is less than cnt reset PWM sig
    reset_rt = 1;
    set_rt = 0;
  end
  else if (~|cnt) begin //When count is zero and spd is non zero set PWM high 
    set_rt = 1;
    reset_rt = 0;
  end
  else begin //Maintain PWM at what its at when count doesn't change and count is below spd
    reset_rt = 0;
    set_rt = 0;
  end

  ////INFER FLOP FOR RIGHT WHEEL/////
always_ff @(posedge clk or negedge rst_n)
  if (!rst_n) begin //Async reset sets to 0
    PWM_rev_rght <= 1'b0;
    PWM_frwrd_rght <= 1'b0;
  end
  else if (reset_rt) begin //spd is below count, set to 0
    PWM_rev_rght <= 1'b0;
    PWM_frwrd_rght <= 1'b0;
  end
  else if (set_rt && rght_rev) //spd is above count, in reverse, set rght_rev PWM
    PWM_rev_rght <= 1'b1;
  else if (set_rt && ~rght_rev)//spd is above count, not reverse, set rght_frwrd PWM
    PWM_frwrd_rght <= 1'b1;
  else begin //Maintain flow when no changes
    PWM_frwrd_rght <= PWM_frwrd_rght;
    PWM_rev_rght <= PWM_rev_rght;
  end

endmodule
