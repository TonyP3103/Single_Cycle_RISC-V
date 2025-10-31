module ram_1KB_instruction #(  parameter MEM_FILE   = "")                       //update to 8KiB instruction memory
(i_clk, i_rst, i_address, o_data);

input logic i_clk;
input logic i_rst;
//input logic i_wren;
input logic [31:0] i_address;
//input logic [31:0] i_data;
output logic [31:0] o_data;
logic [31:0] mem [0:2047]; 


    initial begin
        if (MEM_FILE != "") begin
            $readmemh(MEM_FILE, mem);
        end
    end

always_comb begin 
o_data = mem[i_address[31:2]];
end 

endmodule         