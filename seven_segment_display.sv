module seven_segment_display (binary_input, seg_output);
input logic [3:0] binary_input;
output logic [6:0] seg_output;

always_comb begin
    seg_output = 7'b0;
    case(binary_input)
      4'd0: seg_output = 7'b1000000;
      4'd1: seg_output = 7'b1111001;
      4'd2: seg_output = 7'b0100100;
      4'd3: seg_output = 7'b0110000;
      4'd4: seg_output = 7'b0011001;
      4'd5: seg_output = 7'b0010010;
      4'd6: seg_output = 7'b0000010;
      4'd7: seg_output = 7'b1111000;
      4'd8: seg_output = 7'b0000000;
      4'd9: seg_output = 7'b0010000;
      4'hA: seg_output = 7'b0100000;
      4'hB: seg_output = 7'b0000011;
      4'hC: seg_output = 7'b1000110;
      4'hD: seg_output = 7'b0100001;
      4'hE: seg_output = 7'b0000110;
      4'hF: seg_output = 7'b0001110;
   default : seg_output = 7'b0;
    endcase 
end

endmodule 