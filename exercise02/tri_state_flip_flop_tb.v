module tri_state_flip_flop_tb();

reg clk;				// system clock
reg D;		// models the input signal

wire Q;		

/////// Instantiate DUT /////////
tri_state_flip_flop iDUT(.clk(clk), .D(D), .Q(Q));

initial begin
  clk = 0;
end

always
  #10 clk <= ~clk;	// toggle clock every 10 time units

always begin
  D = 0;
  repeat(4) @(negedge clk);		// wait till 3rd falling clock edge
  D = 1;
  repeat(4) @(posedge clk);
  D = 0;
  repeat(2) @(posedge clk);
  D = 1;
  repeat(3) @(negedge clk);
  
  @(posedge clk);				// wait a clock
  @(posedge clk);
  @(posedge clk);

  $stop();  
end
  
endmodule