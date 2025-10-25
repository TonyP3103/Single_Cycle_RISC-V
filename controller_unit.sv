module controller_unit ( instr_data, o_br_less, o_br_equal, 
                            PCsel, RegWen, Asel, Bsel, ALU_sel, MemRW, wb_select);

input logic [31:0] instr_data;
input logic o_br_less, o_br_equal;

output logic PCsel, RegWen, Asel, Bsel, MemRW;
output logic [3:0] ALU_sel;
output logic [1:0] wb_select; // write back select

// the output should be as follows: PCsel, RegWen, Asel, Bsel, ALU_sel[3:0], MemRW, wb_select[1:0]

logic branch_select;
ALU_encoder  ALU_opcode (   .i_funct7(instr_data[31:25]),
                            .i_funct3(instr_data[14:12]), 
                            .i_opcode(instr_data[6:0]),
                            .o_alu_op(ALU_sel)
                            );

branch_encoder branch_encode (.i_funct3(instr_data[14:12]),
                              .o_br_less(o_br_less), 
                              .o_br_equal(o_br_equal), 
                              .o_pc_sel(branch_select), 
                              .i_br_un()
                              );

localparam R_type = 7'b0110011;
localparam I_type_ALU = 7'b0010011;
localparam I_type_load = 7'b0000011;
localparam S_type = 7'b0100011;
localparam B_type = 7'b1100011;
localparam J_type = 7'b1101111; // JAL
localparam I_type_JALR = 7'b1100111;
localparam U_type_AUIPC = 7'b0010111;
localparam U_type_LUI = 7'b0110111;

 always_comb begin 
    case (instr_data[6:0])
    R_type: begin
        case (ALU_sel) 
            4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b1000, 4'b1001, 4'b1010: begin         //add, sub, sltu, slt, sll, srl, sra, and, or ,xor 
                PCsel = 1'b0;  
                RegWen = 1'b1; 
                Asel = 1'b0; 
                Bsel = 1'b0; 
                MemRW = 1'b0; 
                wb_select = 2'b01; // From ALU
            end
            default: begin
                PCsel = 1'b0; 
                RegWen = 1'b1; 
                Asel = 1'b0; 
                Bsel = 1'b0; 
                MemRW = 1'b0; 
                wb_select = 2'b00; // Default case
            end
        endcase 
end 

    I_type_ALU: begin
        case (ALU_sel) 
            4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b1000, 4'b1001, 4'b1010: begin         //addi, sltiu, slti, slli, srli, srai, andi, ori ,xori 
                PCsel = 1'b0;  
                RegWen = 1'b1; 
                Asel = 1'b0; 
                Bsel = 1'b1; 
                MemRW = 1'b0; 
                wb_select = 2'b01; // From ALU
            end
            default: begin
                PCsel = 1'b0; 
                RegWen = 1'b0; 
                Asel = 1'b0; 
                Bsel = 1'b0; 
                MemRW = 1'b0; 
                wb_select = 2'b00; // Default case
            end
        endcase 
    end 

 I_type_load:
        begin
            PCsel = 1'b0; 
            RegWen = 1'b1; 
            Asel = 1'b0; 
            Bsel = 1'b1; 
            MemRW = 1'b0; 
            wb_select = 2'b00; // From Load Data
        end

    S_type:
        begin
            PCsel = 1'b0; 
            RegWen = 1'b0; 
            Asel = 1'b0; 
            Bsel = 1'b1; 
            MemRW = 1'b1; 
            wb_select = 2'b00; // Default case
        end
    
    B_type:
        begin
        PCsel = branch_select;
        RegWen = 1'b0; 
         Asel = 1'b1;
        Bsel = 1'b1;
        MemRW = 1'b0; 
        wb_select = 2'b01; 
        end 

    J_type:
        begin
        PCsel = 1'b1;
        RegWen = 1'b1;
        Asel = 1'b1;
        Bsel = 1'b1;
        MemRW = 1'b0;
        wb_select = 2'b10; // From PC + 4
        end 

    I_type_JALR:
        begin
        PCsel = 1'b1;
        RegWen = 1'b1;
        Asel = 1'b0;
        Bsel = 1'b1;
        MemRW = 1'b0;
        wb_select = 2'b10; // From PC + 4
        end 

    U_type_AUIPC:
        begin
        PCsel = 1'b0;
        RegWen = 1'b1;
        Asel = 1'b1;
        Bsel = 1'b1;
        MemRW = 1'b0;
        wb_select = 2'b01; // From ALU
        end 

    U_type_LUI:
        begin
        PCsel = 1'b0;
        RegWen = 1'b1;
        Asel = 1'b1;
        Bsel = 1'b1;
        MemRW = 1'b0;
        wb_select = 2'b11; // From B
        end

    default: begin
        PCsel = 1'b0;
        RegWen = 1'b0;
        Asel = 1'b0;
        Bsel = 1'b0;
        MemRW = 1'b0;
        wb_select = 2'b00; // Default case
    end
    endcase 
 end 
   


endmodule 