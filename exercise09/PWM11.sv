module PWM11(clk,rst_n,duty,PWM_sig);

input clk, rst_n;
input [10:0] duty;

output logic PWM_sig;

logic set,reset;
logic [10:0] cnt;

always_ff @(posedge clk or negedge rst_n)
  if (!rst_n)
    cnt <= 11'h000;
  else    
    cnt <= cnt + 1;

always_comb
  if (~|cnt)
    set = 1;
  else if (cnt >= duty) 
    reset = 1;
  else begin
    reset = 0;
    set = 0;
  end

always_ff @(posedge clk or negedge rst_n)
  if (!rst_n)
    PWM_sig <= 1'b0;
  else if (reset)
    PWM_sig <= 1'b0;
  else if (set)
    PWM_sig <= 1'b1;
  else
    PWM_sig <= PWM_sig;

endmodule
