module synch_detect(fall_edge, clk, asynch_sig_in);

input asynch_sig_in;
input clk;
output fall_edge;
wire ff1,ff2,ff3,n1;

dff inst_1(asynch_sig_in, clk, ff1); //Two flops used to 
dff isnt_2(ff1, clk, ff2);	     //prevent meta-stability issues
dff inst_3(ff2, clk, ff3);

xor (n1,ff2,ff3);		//Logic will output high for one clock cycle
and (fall_edge,n1,ff3);		//asynch_sig_in has falling edge

endmodule
