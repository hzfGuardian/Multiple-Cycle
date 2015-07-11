module regFile( clk, rst, // clock and reset
	i_addr1, i_addr2, i_addr3,// read  register addr
	i_wreg,  i_wdata, i_wen,   // write register addr
	o_op1,   o_op2,  o_op3);  // read  register output	
input  wire clk, rst, i_wen;
input  wire [4:0] i_addr1, i_addr2, i_addr3, i_wreg;
input  wire[31:0] i_wdata;
output wire[31:0] o_op1, o_op2, o_op3;

reg [31:0] mem[31:0]; // local registers

assign o_op1 = mem[i_addr1];
assign o_op2 = mem[i_addr2];
assign o_op3 = mem[i_addr3];

always @(posedge clk or posedge rst)
	if (rst == 1'b1) begin
		mem[0] = {32{1'b0}};mem[1] = {32{1'b0}};mem[2] = {32{1'b0}};mem[3] = {32{1'b0}};
		mem[4] = {32{1'b0}};mem[5] = {32{1'b0}};mem[6] = {32{1'b0}};mem[7] = {32{1'b0}};
		mem[8] = {32{1'b0}};mem[9] = {32{1'b0}};mem[10] = {32{1'b0}};mem[11] = {32{1'b0}};
		mem[12] = {32{1'b0}};mem[13] = {32{1'b0}};mem[14] = {32{1'b0}};mem[15] = {32{1'b0}};
		mem[16] = {32{1'b0}};mem[17] = {32{1'b0}};mem[18] = {32{1'b0}};mem[19] = {32{1'b0}};
		mem[20] = {32{1'b0}};mem[21] = {32{1'b0}};mem[22] = {32{1'b0}};mem[23] = {32{1'b0}};
		mem[24] = {32{1'b0}};mem[25] = {32{1'b0}};mem[26] = {32{1'b0}};mem[27] = {32{1'b0}};
		mem[28] = {32{1'b0}};mem[29] = {32{1'b0}};mem[30] = {32{1'b0}};mem[31] = {32{1'b0}};
	end
	else if (i_wen) // write data to register
		mem[i_wreg] = (i_wreg == {5{1'b0}}) ? {32{1'b0}} : i_wdata;
endmodule
