`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.02.2025 19:48:23
// Design Name: 
// Module Name: fp_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fp_top(
    input [31:0] A,
    input [31:0] B,
    input [3:0] control,
    output reg [31:0] result,
    output reg overflow,
    output reg underflow,
    output reg isNaN
    );
    
    wire [31:0] result_add, result_sub, result_mul, result_div;

    fp_add_sub fpa(.A(A), .B(B), .op(1'b0), .result(result_add)); 
    fp_add_sub fps(.A(A), .B(B), .op(1'b1), .result(result_sub));
    fp_mul fpm(.A(A), .B(B), .result(result_mul));
    fp_div fpd(.A(A), .B(B), .result(result_div));
    
    always @(*)    begin
    case (control)  
        4'd0: result = result_add;
        4'd1: result = result_sub;
        4'd2: result = result_mul;
        4'd3: result = result_div;
        default: result = result_add;
    endcase
    end
    
endmodule
