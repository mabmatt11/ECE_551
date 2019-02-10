module inert_intf(clk, rst_n, SS_n, SCLK, MOSI, MISO, INT, ptch, vld);

	input clk, rst_n, MISO, INT;
	output reg vld;
	output [15:0] ptch;
    output SCLK, MOSI, SS_n;
	
	reg wrt, CPH, CPL, CAZH, CAZL;
    wire done;
	reg [15:0] cmd;
    wire [15:0] ptch_rt, AZ, rd_data;
	
	reg [7:0] ptchL, ptchH, AZL, AZH;
	reg [15:0] cntr;
	reg INT_flip, INT_final;
	
	SPI_mstr16 spi(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO),
					.wrt(wrt), .cmd(cmd), .done(done), .rd_data(rd_data));
	inertial_integrator intr(.clk(clk), .rst_n(rst_n), .ptch_rt(ptch_rt), .AZ(AZ), .ptch(ptch), .vld(vld));
	
	typedef enum reg[3:0]{INIT1, INIT2, INIT3, INIT4, INIT5, READY_INVALID, READY_VALID, READ1, READ2, READ3, READ4, READ5} state_t;
	state_t state, nxt_state;

    assign ptch_rt = {ptchH, ptchL};
    assign AZ = {AZH, AZL};
	
	// pitchL register
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			ptchL <= 8'd0;
		else if(CPL)
			ptchL <= rd_data[7:0];
	end
	
	// pitchH register
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			ptchH <= 8'd0;
		else if(CPH)
			ptchH <= rd_data[7:0];
	end
	
	// AZL register
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			AZL <= 8'd0;
		else if(CAZL)
			AZL <= rd_data[7:0];
	end
	
	// AZH register
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			AZH <= 8'd0;
		else if(CAZH)
			AZH <= rd_data[7:0];
	end
	
	// Counting register
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			cntr <= 16'd0;
		else
			cntr = cntr + 1;
	end
	
	// State register
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= INIT1;
		else 
			state <= nxt_state;
	end
	
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			INT_flip <= 1'b0;
		else 
			INT_flip <= INT;
	end
	
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			INT_final <= 1'b0;
		else 
			INT_final <= INT_flip;
	end
	
	always_comb begin
		nxt_state = INIT1;
		wrt = 0;
		cmd = 16'd0;
		vld = 0;
		CPH = 0; 
		CPL = 0;
		CAZH = 0;
		CAZL = 0;
		
		case (state)
			INIT2: begin
				cmd = 16'h1053;
				nxt_state = done ? INIT3 : INIT2;
				wrt = nxt_state == INIT3;
			end
            INIT3: begin
                cmd = 16'h1150;
                nxt_state = done ? INIT4 : INIT3;
                wrt = nxt_state == INIT4;
            end
            INIT4: begin
                cmd = 16'h1460;
                nxt_state = done ? INIT5 : INIT4;
                wrt = nxt_state == INIT5;
            end
            INIT5: begin
                nxt_state = done ? READY_INVALID : INIT5;
            end
            READY_INVALID: begin
                nxt_state = INT_final ? READ1 : READY_INVALID;
            end
            READY_VALID: begin
                vld = 1;
                nxt_state = INT_final ? READ1 : READY_INVALID;
            end
            READ1: begin
                cmd = 16'hA2XX;
                nxt_state = done ? READ2 : READ1;
                wrt = nxt_state == READ2;
            end
            READ2: begin
                cmd = 16'hA3XX;
                nxt_state = done ? READ3 : READ2;
                wrt = nxt_state == READ3;
                CPL = done;
            end
            READ3: begin
                cmd = 16'hACXX;
                nxt_state = done ? READ4: READ3;
                wrt = nxt_state == READ4;
                CPH = done;
            end
            READ4: begin
                cmd = 16'hADXX;
                nxt_state = done ? READ5: READ4;
                wrt = nxt_state == READ5;
                CAZL = done;
            end
            READ5: begin
                CAZH = done;
                nxt_state = done ? READY_VALID : READ5;
            end
			default: begin
				nxt_state = &cntr ? INIT2 : INIT1;
				cmd = 16'h0D02;
				wrt = nxt_state == INIT2;
			end
		endcase
	end
	
endmodule
