module tri_state_flip_flop(Q, clk, D);

input clk;
input D;
output Q;
wire md,mq,sd,clk_n;

not (clk_n,clk); 	//create not-clock for second tri-state en

notif1 #1 (md,D,clk);	//tri-state active high en by normal clk
not (mq,md);
not (weak0,weak1) (md,mq); //weak to prevent contention when signal changes

notif1 #1 (sd,mq,clk_n); //tri-state active high en by not-clock
not (Q,sd);
not (weak0,weak1) (sd,Q);  //weak to prevent contention when signal changes

endmodule
