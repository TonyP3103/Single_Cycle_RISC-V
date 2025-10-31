module wrapper (CLOCK_50, SW, KEY, LEDR, LEDG, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
input logic CLOCK_50;
input logic [9:0] SW;
input logic [0:3] KEY;
output logic [9:0] LEDR;
output logic [9:0] LEDG;
output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

logic [6:0] HEX0_data, HEX1_data, HEX2_data, HEX3_data, HEX4_data, HEX5_data;

single_cycle DUT (
            .i_clk(CLOCK_50),
            .i_reset(KEY[0]),
            .i_io_sw   (SW),
            .o_io_ledr (LEDR),
            .o_io_ledg (LEDG),
            .o_io_lcd  (),
            .o_io_hex0 (HEX0_data),
            .o_io_hex1 (HEX1_data),
            .o_io_hex2 (HEX2_data),
            .o_io_hex3 (HEX3_data),
            .o_io_hex4 (HEX4_data),
            .o_io_hex5 (HEX5_data),
            .o_io_hex6 (),
            .o_io_hex7 (),
            .o_pc_debug (),
            .o_insn_vld ()
);

seven_segment_display hex0_inst (.binary_input(HEX0_data[3:0]), .seg_output(HEX0));
seven_segment_display hex1_inst (.binary_input(HEX1_data[3:0]), .seg_output(HEX1));
seven_segment_display hex2_inst (.binary_input(HEX2_data[3:0]), .seg_output(HEX2));
seven_segment_display hex3_inst (.binary_input(HEX3_data[3:0]), .seg_output(HEX3));
seven_segment_display hex4_inst (.binary_input(HEX4_data[3:0]), .seg_output(HEX4));
seven_segment_display hex5_inst (.binary_input(HEX5_data[3:0]), .seg_output(HEX5));




endmodule 