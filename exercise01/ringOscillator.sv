module ringOscillator(Z,en)

	input en;
	output Z;
	wire n1,n2;

	nand #5 A1(n1,en,Z);
	not #5 I1(n2,n1);
	not #5 I2(Z,n2);

endmodule