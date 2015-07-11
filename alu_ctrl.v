module alu_ctrl(i_aluop, i_func, o_alu_ctrl);

input [1:0] i_aluop;
input [5:0] i_func;
output reg [2:0] o_alu_ctrl;

always@(i_aluop or i_func) begin
	case(i_aluop)
		2'b00:o_alu_ctrl=3'b010;
		2'b01:o_alu_ctrl=3'b110;
		2'b10:begin
			case(i_func)
				6'd32:o_alu_ctrl=3'b010;//add
				6'd34:o_alu_ctrl=3'b110;//sub
				6'd36:o_alu_ctrl=3'b000;//and
				6'd37:o_alu_ctrl=3'b001;//or
				6'd42:o_alu_ctrl=3'b111;//slt
				6'd0:o_alu_ctrl=3'b011;//sll
				6'd2:o_alu_ctrl=3'b100;//srl
			endcase
		end
		2'b11:o_alu_ctrl=3'b001;//ori
	endcase
end

endmodule
