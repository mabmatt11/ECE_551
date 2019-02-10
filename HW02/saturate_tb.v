module saturate_tb();

  reg [15:0] unsigned_err,signed_err;
  reg [9:0]  signed_D_diff;

  wire [9:0] unsigned_err_sat,signed_err_sat;
  wire [6:0] signed_D_diff_sat;

  saturate iDUT(.unsigned_err(unsigned_err), .signed_err(signed_err), .signed_D_diff(signed_D_diff),
		.unsigned_err_sat(unsigned_err_sat), .signed_err_sat(signed_err_sat),
		.signed_D_diff_sat(signed_D_diff_sat));

  initial begin 
    unsigned_err = 16'h4FFF;
    signed_err = 16'h4FFF;
    signed_D_diff = 10'h1FF;
    #10;
    unsigned_err = 16'h0044;
    signed_err = 16'h0044;
    signed_D_diff = 10'h004;
    #10;
    unsigned_err = 16'h8044;
    signed_err = 16'h8044;
    signed_D_diff = 10'h204;
    #10;
    unsigned_err = 16'h03FF;
    signed_err = 16'h01FF;
    signed_D_diff = 10'h03F;
    #10;
    unsigned_err = 16'h0400;
    signed_err = 16'h0200;
    signed_D_diff = 10'h040;
    #10;
    unsigned_err = 16'hA2FF;
    signed_err = 16'hA2FF;
    signed_D_diff = 10'h302;
    #10;
    unsigned_err = 16'h0077;
    signed_err = 16'hFD00;
    signed_D_diff = 10'h000;
    #10;
    unsigned_err = 16'h0000;
    signed_err = 16'hFC00;
    signed_D_diff = 10'h300;
    #10;


    $stop;

    end
endmodule

