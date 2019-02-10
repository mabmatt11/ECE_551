module PWM11(clk, rst_n, duty, PWM_sig);

    input clk, rst_n;
    input [10:0] duty;
    output PWM_sig;

    wire [10:0] count;
    wire set, reset;

    counter counter(.clk(clk), .rst_n(rst_n), .out(count));
    rs_flop rs_flop(.r(reset), .s(set), .clk(clk), .rst_n(rst_n), .q(PWM_sig));

    // Reset flop when counter is full
    assign reset = (count >= duty);

    // Set flop when counter is empty
    assign set = (count == 0);

endmodule

module counter(clk, rst_n, out);

    input clk, rst_n;
    output reg [10:0] out;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            out <= 1'b0;
        // Count up when not resetting
        else
            out <= out + 1;
    end

endmodule

module rs_flop(r, s, clk, rst_n, q);

    input r, s, clk, rst_n;
    output reg q;

    // Basic RS flop functionality
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            q <= 1'b0;
        else if (r)
            q <= 1'b0;
        else if (s)
            q <= 1'b1;
    end

endmodule

