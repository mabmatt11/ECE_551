////////////////////////////////////////////////////////////////////////////////
// Module: intertial_integrator
// Authors: Mandy Becker & Matthew Bachmeier
////////////////////////////////////////////////////////////////////////////////

module inertial_integrator_tb();

    reg clk, rst_n, vld;
    reg [15:0] ptch_rt, AZ;
    wire [15:0] ptch;

    localparam PTCH_RT_OFFSET = 16'h03C2, AZ_OFFSET = 16'hFE80;

    inertial_integrator iDUT(.clk(clk), .rst_n(rst_n), .vld(vld), .ptch_rt(ptch_rt), .AZ(AZ), .ptch(ptch));

    always
        #5 clk = ~clk;

    initial begin
        // Init to zero
        clk = 0;
        rst_n = 0;
        vld = 0;
        ptch_rt = 0;
        AZ = 0;
		@(posedge clk);
        @(negedge clk) rst_n = 1;
        ptch_rt = 16'h1000  + PTCH_RT_OFFSET;
        AZ = 16'h0000;
        vld = 1;

        repeat (500) @(negedge clk);
        ptch_rt = PTCH_RT_OFFSET;

        repeat (1000) @(negedge clk);
        ptch_rt = PTCH_RT_OFFSET - 16'h1000;

        repeat (500) @(negedge clk);
        ptch_rt = PTCH_RT_OFFSET;

        repeat (1000) @(negedge clk);
		AZ = 16'h0800;
		
		repeat (1000) @(negedge clk);
        #10 $stop;
    end

endmodule

