module up_dwn_cnt4(clk,rst_n,en,dwn,cnt);

input clk,rst_n,en,dwn;

output logic [3:0] cnt;

logic [3:0] w1;

initial
  cnt = 4'h0;

always_comb begin
  if (en) begin
    if (dwn) begin
      w1 = cnt - 1;
    end
    else begin
      w1 = cnt + 1;
    end
  end
  else begin
    w1 = cnt;
  end
end

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cnt <= 4'h0;
  end
  else begin
    cnt <= w1;
  end
end

endmodule

