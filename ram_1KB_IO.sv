module ram_1KB_IO #(  parameter MEM_FILE   = "") 
(i_clk, i_rst, i_wren, i_address, i_data, io_enable, o_data, i_io_sw, o_io_ledr, o_io_ledg, o_io_lcd, o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3,o_io_hex4, o_io_hex5,funct3);

/*
 Baseaddress                            Topaddress                              Mapping
 0x1001_1000                            0xFFFF_FFFF                             (Reserved)  -> for now it in the switches'range
 0x1001_0000                            0x1001_0FFF                             Switches(required)

 0x1000_5000                            0x1000_FFFF                             (Reserved)      -> have available memory space but nothing assigned to
 0x1000_4000                            0x1000_4FFF                             LCDControlRegisters

 0x1000_3C00                            0x1000_3FFF                             Seven-segmentLEDs7
 0x1000_3800                            0x1000_3BFF                             Seven-segmentLEDs6
 0x1000_3400                            0x1000_37FF                             Seven-segmentLEDs5
 0x1000_3000                            0x1000_33FF                             Seven-segmentLEDs4
 0x1000_3000                            0x1000_3FFF                             Seven-segmentLEDs7-4


 0x1000_2C00                            0x1000_2FFF                             Seven-segmentLEDs3
 0x1000_2800                            0x1000_2BFF                             Seven-segmentLEDs2
 0x1000_2400                            0x1000_27FF                             Seven-segmentLEDs1
 0x1000_2000                            0x1000_23FF                             Seven-segmentLEDs0
 0x1000_2000                            0x1000_2FFF                             Seven-segmentLEDs3-0


 0x1000_1C00                            0x1000_1FFF                             4th GreenLEDs byte
 0x1000_1800                            0x1000_1BFF                             3rd GreenLEDs byte
 0x1000_1400                            0x1000_17FF                             2nd GreenLEDs byte
 0x1000_1000                            0x1000_13FF                             1st GreenLEDs byte
 0x1000_1000                            0x1000_1FFF                             GreenLEDs(required)


 0x1000_0000                            0x1000_0FFF                             RedLEDs(required)

 0x0000_0800                            0x0FFF_FFFF                             (Reserved)  -> in the DMEM'range but no availabe memory space
 0x0000_0000                            0x0000_07FF                             Memory(2KiB)(required)

*/


input logic i_clk;
input logic i_rst;
input logic i_wren;
input logic io_enable;
input logic  [16:0]  i_address;                 // first nible to seperate the input and output 
input logic [2:0] funct3;
 

input logic [31:0] i_data;
input logic [31:0] i_io_sw;


output logic [31:0] o_data;
output logic [31:0]  o_io_ledr, o_io_ledg, o_io_lcd;
output logic [6:0] o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3, o_io_hex4, o_io_hex5;


logic [31:0] mem_output_buffer [0:4];                //5 32 bits register with each register hold 4 bytes of IO value


logic [7:0] IO [0:19];           // 20 1-byte register at different address      

logic [31:0] mem_input_buffer;                  // take switches as only inputs                                 

logic [7:0] byte_0, byte_1;

logic [31:0] store_data;

assign byte_0 = i_data[7:0];
assign byte_1 = i_data[15:8];



always_ff @(posedge i_clk or negedge i_rst) begin
    if (!i_rst) begin
         mem_output_buffer[0] <= 32'b0;
         mem_output_buffer[1] <= 32'b0;
         mem_output_buffer[2] <= 32'b0;
         mem_output_buffer[3] <= 32'b0;
         mem_output_buffer[4] <= 32'b0;
    end else if (i_wren) begin                              //write to the corresponding io
        mem_output_buffer[i_address[15:12]] <= store_data;  //i_data;                                        //add a register to select what kind of store byte
    end 
end 

always_comb begin
    case (funct3)
    3'b000: begin                                                   //store byte
        store_data = {24'd0, byte_0};
    end 
    3'b001: begin                                                   //store halfword
        store_data = {16'd0, byte_1, byte_0};
    end
    3'b010: begin                                                   //store word
        store_data = i_data;
    end
    default: begin
        store_data = i_data;
        end 
    endcase 
end 

assign mem_input_buffer= i_io_sw;       


assign o_io_ledr =  mem_output_buffer[0];               //0x1000_0000 to 0x1000_0FFF

assign o_io_ledg =  mem_output_buffer[1];               //0x1000_1000 to 0x1000_1FFF

assign o_io_hex0 =  mem_output_buffer[2][6:0];          // 0x1000_2000 to 0x1000_2FFF
assign o_io_hex1 =  mem_output_buffer[2][14:8];         
assign o_io_hex2 =  mem_output_buffer[2][22:16];        
assign o_io_hex3 =  mem_output_buffer[2][30:24];

assign o_io_hex4 =  mem_output_buffer[3][6:0];          //0x1000_3000 to 0x1000_3FFF
assign o_io_hex5 =  mem_output_buffer[3][14:8];

assign o_io_lcd  =  mem_output_buffer[4];               //0x1000_4000 to 0x1000_4FFF

assign o_data = (i_address[16] & io_enable) ? mem_input_buffer : mem_output_buffer[i_address[15:12]];

endmodule
