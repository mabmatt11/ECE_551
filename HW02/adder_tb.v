module adder_tb();

reg [4:0] A,B;
reg cin;
reg [4:0] compare;

wire [3:0] Sum;
wire co;

adder iDUT(.A(A[3:0]),.B(B[3:0]),.cin(cin),.Sum(Sum),.co(co));

//initial $monitor("A: %h B: %h cin: %b Sum: %h co: %b compare: %h", A[3:0], B[3:0], cin, Sum, co, compare); 

initial begin
 for (A = 0; A < 16; A = A + 1) begin
     for (B = 0; B < 16; B = B + 1) begin
        cin = 0;
	#5;
	if ({co,Sum} != compare) begin
	   $display("Test failed");
	   $stop;
        end
        cin = 1;
        #5;
        if ({co,Sum} != compare) begin
	   $display("Test failed");
	   $stop;
        end
      end
   end

  $display("All tests passed!!");
  $stop;
end


always@(A,B,cin) begin

  compare = A+B+cin;

end
endmodule
