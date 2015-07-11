`timescale 1ns / 1ps



module pbdebounce(input wire clk,
	input wire button,
	output reg button_out);
	
	reg [7:0] pbshift;
	wire clk_1ms;

	timer_1ms m0(clk, clk_1ms);

	always@(posedge clk_1ms) 
	begin
		pbshift=pbshift<<1;//����1λ
		pbshift[0]=button;
		if (pbshift==0)
			button_out=0;
		if (pbshift==8'hFF)// pbshift��λȫΪ1
			button_out=1;
	end
endmodule
