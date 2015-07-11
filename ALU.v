`timescale 1ns / 1ps

module ALU(alu_ctrl, op1, op2, result, zero_flag);

input [2:0] alu_ctrl;
input [31:0] op1;
input [31:0] op2;
output reg [31:0] result;
output zero_flag;

assign zero_flag = (result==32'b0);

always @* begin	
	if(alu_ctrl==3'b000) begin
		result = op1 & op2;//and
	end
	
	if(alu_ctrl==3'b001) begin
		result = op1 | op2;//or
	end
	
	if(alu_ctrl==3'b010) begin
		result = op1 + op2;//add
	end
	
	if(alu_ctrl==3'b110) begin
		result = op1 - op2;//sub
	end
	
	if(alu_ctrl==3'b111) begin
		if(op1[31]!=op2[31])
			result = (op1[31] == 1) ? 1 : 0;
		else
			result = (op1 < op2) ? 1 : 0;//slt
	end
	
	if(alu_ctrl==3'b011) begin
			result = {op2[30:0], 1'b0};//sll
	end
	
	if(alu_ctrl==3'b100) begin
			result = {1'b0, op2[31:1]};//srl
	end

end

endmodule
