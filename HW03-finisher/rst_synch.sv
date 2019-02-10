module rst_synch(RST_n,clk,rst_n);

input RST_n,clk; //clock for flops, reset from button
output logic rst_n; //output from logic/button

logic q1,q2; //internal signals for flops

/////////INFER FLIP FLOPS///////////////
always_ff @(negedge clk, negedge RST_n) begin
	if (!RST_n) begin //When button pressed set flops to 0
		q1 <= 1'b0;
		q2 <= 1'b0;
	end
	else begin //when not pressed set to 1
	  q1 <= 1'b1;
	  q2 <= q1;
	end
	rst_n <= q2; //global rst_n gets second flop
end

endmodule