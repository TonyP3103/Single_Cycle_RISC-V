module ram_1KB #(  parameter MEM_FILE   = "")                                   //this ram is now modified into 2KiB
(i_clk, i_rst, i_wren, i_address, i_data, o_data,   funct3 );

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



input logic i_clk;
input logic i_rst;
input logic i_wren;
input logic [2:0] funct3;
input logic [31:0] i_address;                        //increase the address to 9 bits to reach 512 addresses * 4bytes/address = 2KiB
input logic [31:0] i_data;
output logic [31:0] o_data;

 logic [31:0] mem [0:511]; 

logic [31:0] temp_data_0, temp_data_1, temp_data_2, temp_data_3;

logic [7:0] byte_0, byte_1, byte_2, byte_3, byte_4, byte_5, byte_6, byte_7;

logic [7:0] store_byte_0, store_byte_1, store_byte_2, store_byte_3;

logic [15:0] store_halfword;


assign byte_0 = temp_data_0[7:0];
assign byte_1 = temp_data_0[15:8];
assign byte_2 = temp_data_0[23:16];
assign byte_3 = temp_data_0[31:24];

assign byte_4 = temp_data_1[7:0];
assign byte_5 = temp_data_1[15:8];
assign byte_6 = temp_data_1[23:16];
assign byte_7 = temp_data_1[31:24];


assign store_byte_0 = i_data[7:0];
assign store_byte_1 = i_data[15:8];
assign store_byte_2 = i_data[23:16];
assign store_byte_3 = i_data[31:24];



assign store_halfword = i_data[15:0];
  

//create a 9 bit adder here for the mem_address access

always_ff @(posedge i_clk or negedge i_rst) begin
    if (!i_rst) begin
        for (int i = 0; i < 512; i ++)begin
            mem[i] = 32'd0;
        end
    end else if (i_wren) begin
        mem[i_address[8:2]] <= temp_data_2;
        mem[i_address[8:2] + 1'b1] <= temp_data_3;
    end 
end 



always_comb begin
    temp_data_0 = mem[i_address[8:2]];   
    temp_data_1 = mem[i_address[8:2] + 1'b1];
end

always_comb begin
case (i_address[1:0])
    2'b00: begin
        o_data = temp_data_0;
    end 

    2'b01: begin
        o_data = {temp_data_1[7:0],temp_data_0[31:8]};
    end 

    2'b10: begin
        o_data = {temp_data_1[15:0], temp_data_0[31:16]};
    end 

    2'b11: begin
        o_data = {temp_data_1[23:0], temp_data_0[31:24]};
    end

endcase
end 
////////////////////////////////store logic///////////////////////////////
always_comb begin
       //     temp_data_2 = temp_data_0;
       // temp_data_3 = temp_data_1;
    case(funct3)
    3'b000: begin                                                   //store byte
        case(i_address[1:0])
        2'b00: begin
            temp_data_2 = {byte_3, byte_2, byte_1, store_byte_0};
            temp_data_3 = temp_data_1;
        end 

        2'b01: begin
            temp_data_2 = {byte_3, byte_2, store_byte_0, byte_0};
            temp_data_3 = temp_data_1;
        end 

        2'b10: begin
            temp_data_2 = {byte_3, store_byte_0, byte_1, byte_0};
            temp_data_3 = temp_data_1;
        end 

        2'b11: begin
            temp_data_2 = {store_byte_0, byte_2, byte_1, byte_0};
            temp_data_3 = temp_data_1;
        end 
        endcase 
    end 

    3'b001: begin                                                      // store halfword
        case(i_address[1:0])
        2'b00: begin
            temp_data_2 = {byte_3, byte_2, store_halfword};
            temp_data_3 = temp_data_1;
        end 

        2'b01: begin
            temp_data_2 = {byte_3, store_halfword, byte_0};
            temp_data_3 = temp_data_1;
        end 

        2'b10: begin
            temp_data_2 = {store_halfword, byte_1, byte_0};
            temp_data_3 = temp_data_1;
        end 

        2'b11: begin
            temp_data_2 = {store_byte_0, byte_2, byte_1, byte_0};
            temp_data_3 = {temp_data_1[31:8],store_byte_1};
        end 
        endcase 
    end 

    3'b010: begin                                                   //store word
        case(i_address[1:0])
        2'b00: begin
            temp_data_2 = i_data;
            temp_data_3 = temp_data_1;
        end 

        2'b01: begin
            temp_data_2 = {store_byte_2, store_halfword, byte_0};
            temp_data_3 = {temp_data_1[31:8],store_byte_3};
        end 

        2'b10: begin
            temp_data_2 = {store_halfword, byte_1, byte_0};
            temp_data_3 = {temp_data_1[31:16], store_byte_3, store_byte_2};
        end 

        2'b11: begin
            temp_data_2 = {store_byte_0, byte_2, byte_1, byte_0};
            temp_data_3 = {temp_data_1[31:24],store_byte_3, store_byte_2, store_byte_1};
        end 
        endcase 

    end

    default: begin
        temp_data_2 = temp_data_0;
        temp_data_3 = temp_data_1;
    end
    endcase
end 
   
endmodule 


