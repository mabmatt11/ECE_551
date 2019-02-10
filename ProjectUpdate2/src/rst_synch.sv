module rst_synch(RST_n,clk,rst_n);

input RST_n,clk;
output logic rst_n;

logic d1,d2,q1,q2;

always_ff @(negedge clk, negedge RST_n) begin
	if (!RST_n) begin
		q1 <= 1'b0;
		q2 <= q1;
        rst_n <= q2;
	end
	else begin
        q1 <= 1'b1;
        q2 <= q1;
        rst_n <= q2;
	end
end

endmodule
