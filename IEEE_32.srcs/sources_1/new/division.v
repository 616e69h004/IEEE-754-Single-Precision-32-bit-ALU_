`timescale 1ns/1ps
module division( 
input wire clk, 
input wire [31:0] A, 
input wire [31:0] B, 
output wire [31:0] Res ); 
wire [31:0] two = 32'h40000000; 
wire [31:0] r0, t1, u1, r1; 
wire [31:0] t2, u2, r2; 
wire [31:0] t3, u3, r3; 
initial_guess_approx app(.B(B), .X0(r0)); 
wire [31:0] t1v, u1v, r1v; 
mult754 mul1 (.clk(clk), .A(B), .B(r0), .RES(t1v)); 
ADD_SUB sub1 (.A(two), .B(t1v), .OP(1'b1), .out(u1v)); 
mult754 mul2 (.clk(clk), .A(r0), .B(u1v), .RES(r1v)); 
wire [31:0] t2v, u2v, r2v; mult754 mul3 (.clk(clk), .A(B), .B(r1v), .RES(t2v)); 
ADD_SUB sub2 (.A(two), .B(t2v), .OP(1'b1), .out(u2v)); 
mult754 mul4 (.clk(clk), .A(r1v), .B(u2v), .RES(r2v)); 
wire [31:0] t3v, u3v, r3v; 
mult754 mul5 (.clk(clk), .A(B), .B(r2v), .RES(t3v)); 
ADD_SUB sub3 (.A(two), .B(t3v), .OP(1'b1), .out(u3v)); 
mult754 mul6 (.clk(clk), .A(r2v), .B(u3v), .RES(r3v)); 
mult754 mul7 (.clk(clk), .A(A), .B(r3v), .RES(Res)); 
endmodule
