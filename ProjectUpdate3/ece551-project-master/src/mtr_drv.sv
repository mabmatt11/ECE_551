module mtr_drv(clk, rst_n, lft_spd, lft_rev, PWM_rev_lft, PWM_frwrd_lft, rght_spd, rght_rev, PWM_rev_rght, PWM_frwrd_rght);

    input clk, rst_n, lft_rev, rght_rev;
    input [10:0] lft_spd, rght_spd;

    output PWM_rev_lft, PWM_frwrd_lft, PWM_rev_rght, PWM_frwrd_rght;

    wire left_pwm, right_pwm;

    // PWM instance that handles left PWM signals
    PWM11 left_pwm_instance(.clk(clk), .rst_n(rst_n), .duty(lft_spd), .PWM_sig(left_pwm));

    // PWM instance that handles right PWM signals
    PWM11 right_pwm_instance(.clk(clk), .rst_n(rst_n), .duty(rght_spd), .PWM_sig(right_pwm));

    // Assign to PWM_rev_lft only when reversing
    assign PWM_rev_lft = lft_rev ? left_pwm : 0;

    // Assign to PWM_frwrd_lft only when going forward
    assign PWM_frwrd_lft = lft_rev ? 0 : left_pwm;

    // Assign to PWM_rev_rght only when reversing
    assign PWM_rev_rght = rght_rev ? right_pwm : 0;

    // Assign to PWM_frwrd_rght only when going forward
    assign PWM_frwrd_rght = rght_rev ? 0 : right_pwm;

endmodule

