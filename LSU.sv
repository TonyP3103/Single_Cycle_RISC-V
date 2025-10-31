module LSU (i_clk, i_rst, i_lsu_data, i_lsu_addr, i_lsu_wren, i_io_sw, i_io_btn, o_io_ledr, o_io_ledg, o_io_lcd, o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3,o_io_hex4, o_io_hex5, o_ld_data,funct3); 
 

 /*
 Baseaddress                            Topaddress                              Mapping
 0x1001_1000                            0xFFFF_FFFF                             (Reserved)  -> for now it in the switches'range
 0x1001_0000                            0x1001_0FFF                             Switches(required)

 0x1000_5000                            0x1000_FFFF                             (Reserved)      -> have available memory space but nothing assigned to
 0x1000_4000                            0x1000_4FFF                             LCDControlRegisters
 0x1000_3000                            0x1000_3FFF                             Seven-segmentLEDs7-4
 0x1000_2000                            0x1000_2FFF                             Seven-segmentLEDs3-0
 0x1000_1000                            0x1000_1FFF                             GreenLEDs(required)
 0x1000_0000                            0x1000_0FFF                             RedLEDs(required)

 0x0000_0800                            0x0FFF_FFFF                             (Reserved)  -> in the DMEM'range but no availabe memory space
 0x0000_0000                            0x0000_07FF                             Memory(2KiB)(required)

*/

input logic i_clk, i_rst, i_lsu_wren;
input logic [2:0] funct3;
 
input logic [31:0] i_lsu_data;                                   // the input data for LSU comes from output 2 of register files                                                                 
input logic [31:0] i_lsu_addr;                                  //the address for LSU comes from ALU
input logic [31:0] i_io_sw;
input logic [31:0] i_io_btn;

output logic [31:0]  o_io_ledr, o_io_ledg, o_io_lcd, o_ld_data;
output logic [6:0] o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3, o_io_hex4, o_io_hex5;


logic [31:0] data_data, io_data;

logic data_mem_enable, io_mem_enable;
logic o_data_wren, o_io_wren;
logic [31:0] o_data_mem, o_data_io;
logic data_enable, io_enable;


Decoder  decoder_inst ( .i_ls_address(i_lsu_addr[31:28]),                               //take the msb nible
                        .store_enable(i_lsu_wren), 
                        .i_data(i_lsu_data), 
                        .o_data_wren(o_data_wren), 
                        .o_data_mem(o_data_mem), 
                        .o_io_wren(o_io_wren), 
                        .o_data_io(o_data_io),
                        .data_enable(data_enable), 
                        .io_enable(io_enable)
);


// each ram only need to access last 8 bits of the address


ram_1KB #(.MEM_FILE(""))                              // modified into 2KiB memory
         ram_data (.i_clk(i_clk),
                   .i_rst(i_rst),
                   .i_wren(o_data_wren),
                   .i_address(i_lsu_addr[31:0]),
                   .i_data(o_data_mem), 
                   .o_data(data_data),
                   .funct3(funct3)    
                        );

ram_1KB_IO   ram_1KB_IO_DUT (	.i_clk(i_clk), 
                                .i_rst(i_rst),
                                .i_wren(o_io_wren), 
				.io_enable(io_enable),
                                .i_address(i_lsu_addr[16:0]), // 17 lsb of addresses for IO                             
                                .i_data(o_data_io), 
                                .o_data(io_data), 
                                .i_io_sw(i_io_sw), 
                                .o_io_ledr(o_io_ledr), 
                                .o_io_ledg(o_io_ledg), 
                                .o_io_lcd(o_io_lcd), 
                                .o_io_hex0(o_io_hex0), 
                                .o_io_hex1(o_io_hex1), 
                                .o_io_hex2(o_io_hex2), 
                                .o_io_hex3(o_io_hex3),
                                .o_io_hex4(o_io_hex4), 
                                .o_io_hex5(o_io_hex5),
                                .funct3(funct3)                     //add function_3 to store load byte and half word
                                );

logic  [1:0] lsu_sel;

assign lsu_sel = {io_enable, data_enable};

LSU_MUX LSU_MUX_inst (  .data_data(data_data), 
                        .io_data(io_data), 
                        .lsu_sel(lsu_sel), 
                        .lsu_data_out(o_ld_data)
                );

endmodule   