module duty(ptch_D_diff_sat,ptch_err_sat,ptch_err_I,rev,mtr_duty);

localparam MIN_DUTY = 15'h03D4; //980

input signed [6:0] ptch_D_diff_sat;
input signed [9:0] ptch_err_sat,ptch_err_I;

output rev;
output [11:0] mtr_duty;

wire signed [9:0] ptch_P_term,ptch_I_term;
wire signed [10:0] ptch_D_term;
wire signed [11:0] ptch_PID,ptch_PID_abs;

reg [11:0] x;

assign ptch_D_term = ptch_D_diff_sat*$signed(9);

assign ptch_P_term = (ptch_err_sat>>>1) + (ptch_err_sat>>>2); //ptch_err_sat*(3/4)

assign ptch_I_term = ptch_err_I>>>1;

assign ptch_PID = ptch_D_term + ptch_P_term + ptch_I_term; //max value 1204

assign rev = ptch_PID[11];

always @* begin

  if (ptch_PID[11] == 1'b1) begin
     x = -ptch_PID;
  end 
  else begin
     x = ptch_PID;
  end
end

assign ptch_PID_abs = x;

assign mtr_duty = MIN_DUTY + ptch_PID_abs; //max value 2184 will overflow with 11 bits.
					   //need 12 bits to prevent overflow for unsigned number.

endmodule
