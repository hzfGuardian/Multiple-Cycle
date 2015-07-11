`timescale 1ns / 1ps

module mux4_1(A, B, C, D, ctrl, S);
	 parameter N=32;
	 input wire [N-1:0] A, B, C, D;
	 input wire [1:0] ctrl;
	 output wire [N-1:0] S;
    wire [N-1:0]ta, tb, tc, td;
	 wire [N-1:0] en0, en1;
	 
	 assign en0 = {N{ctrl[0]}};
	 assign en1 = {N{ctrl[1]}};

    and a0_gate[N-1:0](ta, A, ~en1, ~en0);
    and a1_gate[N-1:0](tb, B, ~en1, en0);
    and a2_gate[N-1:0](tc, C, en1, ~en0);
    and a3_gate[N-1:0](td, D, en1, en0);
    
    or o_gate[N-1:0](S, ta, tb, tc, td);
    
endmodule
