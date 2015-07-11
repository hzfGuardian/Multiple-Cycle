`timescale 1ns / 1ps

module ctrl(
	input clk,
	input rst, 
	input [5:0] OP, 
	input [5:0] funct, 
	output [1:0] RegDst, 
	output RegWrite, 
	output ALUSrcA,
	output IorD,
	output IRWrite,
	output MemRead,
	output MemWrite,
	output [1:0] MemtoReg,
	output [1:0] PCWriteCond,
	output PCWrite,
	output wire [1:0] ALUOp,
	output wire [1:0] ALUSrcB,
	output wire [1:0] PCSource,
	output reg [3:0] state
);

wire [15:0] equal;

parameter IF=4'b0000, ID=4'b0001, EX_LS=4'b0010, 
			MEM_RD=4'b0011, WB_LS=4'b0100, MEM_ST=4'b0101, 
			EX_R=4'b0110, WB_R=4'b0111, BR_CPN=4'b1000, J_CPN=4'b1001,
			EX_ADDI=4'b1010, EX_ORI=4'b1011, WB_I=4'b1100, BNE_CPN=4'b1101,
			JAL_WB=4'b1110, JR_CPN=4'b1111;

initial begin
	state <= 4'b1111;
end

always @(posedge clk or posedge rst)
	if(rst==1) state <= 4'b1111;
	else begin
		case(state)
			IF: state <= ID;//state 0
				
			ID://state 1
			begin
				case(OP[5:0])
					6'b000000://R-Type
						state <= EX_R;
					6'b000010://Jump
						state <= J_CPN;
					6'b100011,
					6'b101011://Load or Store
						state <= EX_LS;
					6'b000100://BEQ
						state <= BR_CPN;
					6'b001000://ADDI
						state <= EX_ADDI;
					6'b001101://ORI
						state <= EX_ORI;
					6'b000101://BNE
						state <= BNE_CPN;
					6'b000011://JAL
						state <= JAL_WB;
					default:state <= EX_R;				
				endcase
			end
			
			EX_LS://state 2
			begin
				case(OP[5:0])
					6'b100011: state <= MEM_RD;//LW, goto 3
					6'b101011: state <= MEM_ST;//SW, goto 5
				endcase
			end
			
			MEM_RD://state 3
			begin
				state <= WB_LS;
			end

			WB_LS://state 4
			begin
				state <= IF;
			end
			
			MEM_ST://state 5
			begin
				state <= IF;
			end
			
			EX_R://state 6, excution of R-Type
			begin
				state <= WB_R;
			end
		
			WB_R://state 7, write back register
			begin
				if(funct==6'b001000)
					state <= JR_CPN;
				else
					state <= IF;
			end
			
			BR_CPN://state 8
			begin
				state <= IF;
			end

			J_CPN: //state 9
			begin
				state <= IF;
			end
			
			EX_ADDI: //state 10, addi
			begin
				state <= WB_I;
			end
			
			EX_ORI: //state 11, ori
			begin
				state <= WB_I;
			end
			
			WB_I: //state 12, write back I type
			begin
				state <= IF;
			end
			
			BNE_CPN://state 13, BNE
			begin
				state <= IF;
			end
			
			JAL_WB://state 14, JAL
			begin
				state <= J_CPN;
			end
			
			JR_CPN://state 15, JR
				state <= IF;
			
			default: state <= IF;
		endcase
	end

assign equal[0] = (state==4'b0000);
assign equal[1] = (state==4'b0001);
assign equal[2] = (state==4'b0010);
assign equal[3] = (state==4'b0011);
assign equal[4] = (state==4'b0100);
assign equal[5] = (state==4'b0101);
assign equal[6] = (state==4'b0110);
assign equal[7] = (state==4'b0111);
assign equal[8] = (state==4'b1000);
assign equal[9] = (state==4'b1001);
assign equal[10] = (state==4'b1010);
assign equal[11] = (state==4'b1011);
assign equal[12] = (state==4'b1100);
assign equal[13] = (state==4'b1101);
assign equal[14] = (state==4'b1110);
assign equal[15] = (state==4'b1111);

assign RegDst[0] = equal[7];
assign RegDst[1] = equal[14];
assign RegWrite = equal[4] | equal[7] | equal[12] | equal[14];
assign ALUSrcA = equal[2] | equal[6] | equal[8] | equal[10] | equal[11] | equal[13];
assign IorD = equal[3] | equal[5];
assign IRWrite = equal[0];
assign MemRead = equal[0] | equal[3];
assign MemWrite = equal[5];
assign MemtoReg[0] = equal[4];
assign MemtoReg[1] = equal[14];
assign PCWriteCond = {equal[13], equal[8]};
assign PCWrite = equal[0] | equal[9] | equal[15];
assign ALUOp = {equal[6] | equal[11], equal[8] | equal[11] | equal[13]};
assign ALUSrcB = {equal[1] | equal[2] | equal[10] | equal[11], equal[0] | equal[1]};
assign PCSource = {equal[9] | equal[15], equal[8] | equal[13] | equal[15]};

endmodule
