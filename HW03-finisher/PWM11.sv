module PWM11(clk,rst_n,duty,PWM_sig);

input clk, rst_n; //clock and async reset for flops
input [10:0] duty; //What the duty cycle will be, higher the number the more power

output logic PWM_sig; //The Power Width Modulation signal running the wheels

logic set,reset; //Internal signals for managing the PWM
logic [10:0] cnt; //Internal count signal for the length of a period
                  // 50Mhz/2048 ~~ 19000 Hz

////////////Infer Counter Flop/////////////
always_ff @(posedge clk or negedge rst_n)
  if (!rst_n)
    cnt <= 11'h000; 
  else    
    cnt <= cnt + 1;

////////Infer Combination Logic///////////
always_comb
  if (cnt >= duty) begin //When duty is below count reset is asserted
	reset = 1;
	set = 0;
  end
  else if (~|cnt) begin //When count is at 0 and duty is not 0, set is asserted
	set = 1;
	reset = 0;
  end
  else begin //Default both set and reset to 0
    set = 0;
    reset = 0;
  end

/////////Infer State Flop//////////////
always_ff @(posedge clk or negedge rst_n)
  if (!rst_n) //Async reset to 0
    PWM_sig <= 1'b0;
  else if (reset) // When reset asserted, flop is 0
    PWM_sig <= 1'b0;
  else if (set) // When set is asserted PWM is high
    PWM_sig <= 1'b1;
  else //When reset hasn't been asserted stay where it was at
    PWM_sig <= PWM_sig;

endmodule
