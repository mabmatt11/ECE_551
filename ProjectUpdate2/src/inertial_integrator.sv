////////////////////////////////////////////////////////////////////////////////
// Module: intertial_integrator
// Authors: Matthew Wahner & Tyler Luedtke
////////////////////////////////////////////////////////////////////////////////

module inertial_integrator(clk, rst_n, vld, ptch_rt, AZ, ptch);

    input clk, rst_n, vld;
    input signed [15:0] ptch_rt, AZ;
    output signed [15:0] ptch;

    reg [26:0] ptch_int, nxt_ptch_int;

    wire signed [15:0] ptch_rt_comp, AZ_comp;
	wire signed [15:0] ptch_acc;
    wire signed [25:0] ptch_acc_product;
    wire signed [26:0] fusion_ptch_offset;

    localparam PTCH_RT_OFFSET = 16'h03C2, AZ_OFFSET = 16'hFE80;

    assign ptch = ptch_int[26:11];
    assign ptch_rt_comp = $signed(ptch_rt) - $signed(PTCH_RT_OFFSET);
	
	//acceleration in Z direction
    assign AZ_comp = AZ - $signed(AZ_OFFSET);
	
	//calculate fudge factor
    assign ptch_acc_product = AZ_comp * $signed(327);
	
	//calculate pitch angle from acceleration
    assign ptch_acc = {{3{ptch_acc_product[25]}}, ptch_acc_product[25:13]};
	
	//determine if ptch_int should be going up or down
    assign fusion_ptch_offset = (ptch_acc > ptch) ? 27'h0000400 : 27'hFFFFC00;

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            ptch_int <= 27'd0;
        else
            ptch_int <= nxt_ptch_int;

    always_comb begin
        nxt_ptch_int = vld ? ptch_int - {{11{ptch_rt_comp[15]}}, ptch_rt_comp} + (fusion_ptch_offset) : ptch_int;
    end

endmodule

