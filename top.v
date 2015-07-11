`timescale 1ns / 1ps

module top(clk, btn, switch, anode, segment, led);
//I.O.
input clk;
input [6:0] switch;
input [1:0] btn;
output [15:0] segment;
output [11:0] anode;
output [3:0] led;

//a real clock, it can be chosen as clk or btn_out
wire realCLK;

//Register
reg [31:0] IReg, MDReg;

//clock count
reg [7:0] clk_cnt;

//Memory
wire [31:0] MemData, WriteData;

//PC register
wire rst;
wire [1:0] btn_out;
wire [8:0] addr;
reg [31:0] pc;
wire [31:0] new_pc;
wire EN_PC, beq_brh, bne_brh, or_in;

//CPU controller
wire RegWrite, ALUSrcA, IorD, IRWrite, MemRead, MemWrite, PCWrite;
wire [1:0] ALUOp, ALUSrcB, PCSource, PCWriteCond, RegDst, MemtoReg;

//Register File
wire [4:0] i_wreg;
wire [31:0] i_wdata, o_rdata1, o_rdata2;
reg [31:0] regA, regB;
wire [31:0] register; // local registers we choose to display

//ALU
wire [31:0] alu_op1, alu_op2, alu_result;
wire Zero;
reg [31:0] ALUOut;

//ALU controller
wire [2:0] o_alu_ctrl;

wire [31:0] ext_32;
reg [31:0] display32num;
wire ORImme;
wire [31:0] Immd, u_ext32;

//anti-jitter
pbdebounce pb0(clk, btn[0], btn_out[0]);
pbdebounce pb1(clk, btn[1], btn_out[1]);

assign rst = btn_out[1];
assign ORImme = (IReg[31:26]==6'b001101);

//CPU controller(FSM)
ctrl ctl(realCLK, rst, IReg[31:26], IReg[5:0], RegDst, RegWrite, ALUSrcA, IorD, IRWrite, MemRead, MemWrite,
	MemtoReg, PCWriteCond, PCWrite, ALUOp, ALUSrcB, PCSource, led);

and (beq_brh, PCWriteCond[0], Zero),
	(bne_brh, PCWriteCond[1], ~Zero);
or (or_in, beq_brh, bne_brh),
	(EN_PC, or_in, PCWrite);

always @(posedge realCLK or posedge rst)
	if(rst)
		pc = 0;
	else if(EN_PC)
		pc = new_pc;//update PC

mux2_1 m0(btn_out[0], clk, switch[6], realCLK);//decide the clock

mux2_1 #(9) m1(pc[10:2], ALUOut[10:2], IorD, addr);

Memory mem(addr, ~realCLK, WriteData, MemData, MemWrite);

assign WriteData = regB;

always @(posedge realCLK or posedge rst) begin
	if(rst) begin
		IReg <= 0;
		MDReg <= 0;
		regA <= 0;
		regB <= 0;
		ALUOut <= 0;
	end
	else begin
		if(IRWrite)	IReg <= MemData;
		MDReg <= MemData;
		regA <= o_rdata1;
		regB <= o_rdata2;
		ALUOut <= alu_result;
	end
end

mux4_1 #(5) m2(IReg[20:16], IReg[15:11], 5'b11111, 5'b0, RegDst, i_wreg);//choose the write Reg
mux4_1 m3(ALUOut, MDReg, pc, 32'b0, MemtoReg, i_wdata);

regFile rf(realCLK, rst, IReg[25:21], IReg[20:16], switch[4:0], i_wreg, i_wdata, RegWrite,
	o_rdata1, o_rdata2, register);

mux2_1 m4(pc, regA, ALUSrcA, alu_op1);

signext sex(IReg[15:0], ext_32);
unsign_ext usex(IReg[15:0], u_ext32);
mux4_1 m5(regB, 32'h4, Immd, {ext_32[29:0], 2'b00}, ALUSrcB, alu_op2);
//Immd, u_ext32
alu_ctrl acl(ALUOp, IReg[5:0], o_alu_ctrl);
ALU au(o_alu_ctrl, alu_op1, alu_op2, alu_result, Zero);

mux4_1 m6(alu_result, ALUOut, {pc[31:28], IReg[25:0], 2'b00}, regA, PCSource, new_pc);
mux2_1 m7(ext_32, u_ext32, ORImme, Immd);

/*******************************************************************************************/	 
display16bits dp16(clk, {clk_cnt, pc[7:0]}, anode[3:0], segment[7:0]);//16-bit display
display32bits dp32(clk, display32num, anode[11:4], segment[15:8]);

always @(posedge realCLK or posedge rst) begin
	if(rst==1)
		clk_cnt = 8'b0;
	else begin
		clk_cnt = clk_cnt + 1;
	end
end

always @(switch[5]) begin
	if(switch[5]==0)
		display32num = register;
	else
		display32num = IReg;
end

endmodule
