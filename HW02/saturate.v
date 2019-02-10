module saturate(unsigned_err, signed_err, signed_D_diff, unsigned_err_sat, 
		signed_err_sat, signed_D_diff_sat);

input [15:0] unsigned_err,signed_err;
input [9:0] signed_D_diff;

output [9:0] unsigned_err_sat,signed_err_sat;
output [6:0] signed_D_diff_sat;

assign unsigned_err_sat = (|unsigned_err[15:10]) ? 10'h3FF :
				          unsigned_err[9:0];

assign signed_err_sat = (~signed_err[15] && |signed_err[14:8]) ? 10'h1FF :
			(signed_err[15] && ~&signed_err[14:9]) ? 10'h200 :
							  signed_err[9:0];

assign signed_D_diff_sat = (~signed_D_diff[9] && |signed_D_diff[8:6]) ? 7'h3F :
			   (signed_D_diff[9] && ~&signed_D_diff[8:7]) ? 7'h40 :
						            signed_D_diff[6:0];

endmodule

