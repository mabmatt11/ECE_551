module adder(A,B,cin,Sum,co);

input [3:0] A,B;
input cin;

output [3:0] Sum;
output co;

assign {co,Sum} = A + B + cin;

endmodule
