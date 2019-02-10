module latches(input clk,rst_n,en,r,s,d,output logic q);

/*
a) The code on the homework document is not correct. It will
not synthesize as a latch. It is not using a posedge or negedge
clk as the sensativity list in the always condition. It will
synthesize as a mux.
*/

//logic q;

// b)
always_ff @(posedge clk)

if (!rst_n)
  q <= 1'b0;
else
  q <= d;


// c)
always_ff @(posedge clk or negedge rst_n)

if (!rst_n)
  q <= 1'b0;
else if (en)
  q <= d;
else
  q <= q;


// d)
always_ff @(posedge clk or negedge rst_n)

if (!rst_n)
  q <= 1'b0;
else if (r)
  q <= 1'b0;
else if (s)
  q <= d;
else
  q <= q;

/*
e) No, using always_ff does not ensure that it will synthesize 
as a flop. What it will do is warn the user if it is not
synthesized as a flop.
*/


endmodule
