module duty_tb();

reg signed [6:0] ptch_D_diff_sat;
reg signed [9:0] ptch_err_sat,ptch_err_I;

wire signed rev;
wire signed [11:0] mtr_duty;

duty iDUT(.ptch_D_diff_sat(ptch_D_diff_sat),.ptch_err_sat(ptch_err_sat),.ptch_err_I(ptch_err_I),
	  .rev(rev),.mtr_duty(mtr_duty));

initial begin
ptch_D_diff_sat = 7'b0000000;
ptch_err_sat = 10'h000;
ptch_err_I = 10'h000;
#10;
ptch_D_diff_sat = 7'b1001000;
ptch_err_sat = 10'h02F;
ptch_err_I = 10'h02F;
#10;
ptch_D_diff_sat = 7'b0001101;
ptch_err_sat = 10'h22F;
ptch_err_I = 10'h02F;
#10;
ptch_D_diff_sat = 7'b0001101;
ptch_err_sat = 10'h02F;
ptch_err_I = 10'h22F;
#10;
ptch_D_diff_sat = 7'b1001101;
ptch_err_sat = 10'h22F;
ptch_err_I = 10'h02F;
#10;
ptch_D_diff_sat = 7'b1001101;
ptch_err_sat = 10'h02F;
ptch_err_I = 10'h22F;
#10;
ptch_D_diff_sat = 7'b0001101;
ptch_err_sat = 10'h22F;
ptch_err_I = 10'h22F;
#10;
ptch_D_diff_sat = 7'b0001101;
ptch_err_sat = 10'h02F;
ptch_err_I = 10'h02F;
#10;
ptch_D_diff_sat = 7'b1001101;
ptch_err_sat = 10'h22F;
ptch_err_I = 10'h22F;
#10;
ptch_D_diff_sat = 7'b0111111;
ptch_err_sat = 10'h1FF;
ptch_err_I = 10'h1FF;
#10;
ptch_D_diff_sat = 7'b1111111;
ptch_err_sat = 10'h2FF;
ptch_err_I = 10'h2FF;
#10;

$stop;
end

endmodule
