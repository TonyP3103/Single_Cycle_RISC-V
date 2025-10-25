module Decoder ( i_ls_address, store_enable, i_data, o_data_wren, o_data_mem, o_io_wren, o_data_io,   data_enable,io_enable);

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




input logic [3:0] i_ls_address;                //load-store address                                                            
input logic store_enable;
input logic [31:0] i_data;                      //data to be stored

//output logic o_instr_wren;             
//output logic [31:0] o_data_instr;

output logic o_data_wren;                  
output logic [31:0] o_data_mem;                   

output logic o_io_wren;                     
output logic [31:0] o_data_io;


output logic data_enable;
output logic io_enable;

//i_ls_address[3:0] from the ALU[31:28]
assign io_enable   = ~|i_ls_address[3:1] & i_ls_address[0]; // 0x1000_0000 –  0x1001_0FFF
assign data_enable = ~|i_ls_address[3:0]; // 0x0000_0000 – 0x0000_07FF
    
// Write enables
assign o_data_wren = data_enable & store_enable;
assign o_io_wren   = io_enable   & store_enable;

// Always forward data, enables control actual writes
assign o_data_mem = i_data;
assign o_data_io  = i_data;

endmodule 