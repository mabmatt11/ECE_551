module balance_cntrl_chk_tb();

reg [31:0] stim[0:999]; //input vector from file
 // stim[31] = rst_n
 // stim[30] = vld
 // stim[29:14] = ptch
 // stim[13:2] = ld_cell_diff
 // stim[1] = rider_off
 // stim[0] = en_steer 

reg [31:0] stim_o; //input vector to DUT 

reg clk; //clock!

reg [9:0] mem_addr; //counter for looping through file vectors

reg [23:0] resp[0:999]; //output response vector to file
 // resp[23] = lft_rev
 // resp[22:12] = lft_spd
 // resp[11] = rght_rev
 // resp[10:0] = rght_spd

wire [23:0] resp_o; //output vector from DUT

/////////// Instantiate the DUT /////////
balance_cntrl iDUT(.rst_n(stim_o[31]),.vld(stim_o[30]),.ptch(stim_o[29:14]),.ld_cell_diff(stim_o[13:2]),
                   .rider_off(stim_o[1]),.en_steer(stim_o[0]),.lft_rev(resp_o[23]),.lft_spd(resp_o[22:12]),
                   .rght_rev(resp_o[11]),.rght_spd(resp_o[10:0]),.clk(clk));

initial begin
  $readmemh("balance_cntrl_stim.hex", stim); //get data from files
  $readmemh("balance_cntrl_resp.hex", resp);
 // $display("%h ,, %h",resp[2], stim[2]);
end

initial begin  // get the clock going
  clk = 0;
  forever 
    #5 clk = ~clk;
end

initial begin
  for (mem_addr = 0; mem_addr < 1000; mem_addr = mem_addr + 1) begin //go through the entire files vectors
    stim_o = stim[mem_addr]; //set input to DUT from file vector
   // $display("INPUT: %d, OUR INPUT: %d", stim[mem_addr], stim_o);
    @(posedge clk) //wait a clock period and one time unit
    #1;
    $display("Our response: %h, Expected: %h", resp_o, resp[mem_addr]); //show user values
    if (resp_o != resp[mem_addr]) begin //when output is incorrect
      $display("YOU FAILED! At %d", mem_addr); //show where it failed and quit
      $stop;
    end
  end
  $display("YOU PASSED YOU'RE AMAZING"); //when all vectors pass!
  $stop;
end

endmodule 
