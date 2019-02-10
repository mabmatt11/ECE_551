module PB_release(clk, rst_n, PB, released);

input clk,rst_n,PB;

output released;
logic ff1,ff2,ff3;

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ff1 <= 1'b1;
    ff2 <= 1'b1;
    ff3 <= 1'b1;
  end
  else begin
    ff1 <= PB;
    ff2 <= ff1;
    ff3 <= ff2;
  end
end

assign released = (~ff3)&ff2;

endmodule
