module unsign_ext(i_16,o_32);
input wire[15:0] i_16;
output reg [31:0] o_32;
always @(i_16)
	o_32 <= {16'b0, i_16[15:0]};
endmodule 