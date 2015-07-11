module mux2_1(A, B, C, S);
parameter N=32;
// N: 1, 2, 5, 9, 32
input wire [N-1:0] A, B;
input wire C;
output wire [N-1:0] S;
assign S = C ? B : A;
endmodule

//mux2_1 #(.N(32)) mux2(a, b, c, s);