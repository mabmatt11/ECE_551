module PB_release(clk, rst_n, PB, released);

input clk,rst_n,PB; //clock and async reset for flops
		    //PB is input from button

output released;  //output from button press logic
logic ff1,ff2,ff3; //flops used to capture input from button

////////INFER FLIP FLOPS FOR BUTTON//////////
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin //Preset when asych deasserted
    ff1 <= 1'b1;
    ff2 <= 1'b1;
    ff3 <= 1'b1;
  end
  else begin //three flops in a row
    ff1 <= PB;
    ff2 <= ff1;
    ff3 <= ff2;
  end
end

assign released = (~ff3)&ff2; //When there is a falling edge on the button

endmodule
