module up_dwn_cnt4(clk,rst_n,en,dwn,cnt);

input clk,rst_n,en,dwn; //clock and asych reset for flops
			//input signals for counting

output logic [3:0] cnt; //output from counter

logic [3:0] w1; //internal signal used by counter

initial
  cnt = 4'h0; //Initialize counter to 0

//////INFER COMBINATIONAL LOGIC///////
always_comb begin
  if (en) begin //When counter is enabled count
    if (dwn) begin //if down enabled count down
      w1 = cnt - 1;
    end
    else begin //otherwise count up
      w1 = cnt + 1;
    end
  end
  else begin
    w1 = cnt; //maintain if not enabled
  end
end

////////INFER COUNTER FLIP FLOP//////////
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin //async reset to 0
    cnt <= 4'h0;
  end
  else begin //Flop gets data from combinational logic
    cnt <= w1;
  end
end

endmodule

