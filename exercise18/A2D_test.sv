module A2D_test(clk,RST_n,SEL,LED,SCLK,SS_n,MOSI,MISO);

  input clk,RST_n;		// clk and unsynched reset from PB
  input SEL;			// from 2nd PB, cycle through outputs
  input MISO;			// from A2D
  
  output [7:0] LED;
  output SS_n;			// active low slave select to A2D
  output SCLK;			// SCLK to A2D SPI
  output MOSI;
  
  ////////////////////////////////////////////////////////////
  // Declare any needed internal registers (like counters) //
  //////////////////////////////////////////////////////////
  logic [18:0] cnt_19;
  logic [1:0] cnt_2;
  
  ///////////////////////////////////////////////////////
  // Declare any needed internal signals as type wire //
  /////////////////////////////////////////////////////
  logic nxt;
  logic [11:0] lft_ld,rght_ld,batt;
  logic en_2bit;
  logic rst_n;

  //////////////////////////////////////////////////
  // Infer 19-bit counter to set conversion rate //
  ////////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  cnt_19 <= 19'h00000;
    else if (cnt_19 == 19'h7FFFF)
	  cnt_19 <= 19'h00000;
    else 
	  cnt_19 <= cnt_19 + 1;
	  
  assign nxt = &cnt_19;
  
  ////////////////////////////////////////////////////////////////
  // Infer 2-bit counter to select which output to map to LEDs //
  //////////////////////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  cnt_2 <= 2'b00;
	else if (en_2bit && cnt_2 != 2'b10) 
	  cnt_2 <= cnt_2 + 1;
	else if (en_2bit && cnt_2 == 2'b10)
	  cnt_2 <= 2'b00;
	  
  //////////////////////////////////////////////////////
  // Infer Mux to select which output to map to LEDs //
  //////////////////////////////////////////////////// 
  assign LED = (cnt_2 == 2'b00) ? lft_ld[11:4] :
               (cnt_2 == 2'b01) ? rght_ld[11:4] :
                                  batt[11:4];			   
	
  //////////////////////
  // Instantiate DUT //
  ////////////////////  
  A2D_intf iDUT(.clk(clk),.rst_n(rst_n),.nxt(nxt),.lft_ld(lft_ld),
                .rght_ld(rght_ld),.batt(batt),.SS_n(SS_n),.SCLK(SCLK),
				.MOSI(MOSI),.MISO(MISO));
			   
  ///////////////////////////////////////////////
  // Instantiate Push Button release detector //
  /////////////////////////////////////////////
  PB_release iPB(.clk(clk),.rst_n(rst_n),.PB(SEL),.released(en_2bit));
  
  /////////////////////////////////////
  // Instantiate reset synchronizer //
  ///////////////////////////////////
  rst_synch iRST(.clk(clk),.RST_n(RST_n),.rst_n(rst_n));   
	  
endmodule
  
