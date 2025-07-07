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
    //input [31:0] A,
    //input [31:0] B,
    
    input signed [31:0] A_decimal,
    input signed [31:0] A_fractional,
    input [31:0] A_scaling_factor,
    input signed [31:0] B_decimal,
    input signed [31:0] B_fractional,
    input [31:0] B_scaling_factor,
    
    input [3:0] control,
    output reg [31:0] result,
    output reg overflow,
    output reg underflow,
    output reg isNaN
    );
    
    wire [31:0] result_add, result_sub, result_mul, result_div;
    wire [31:0] A_ieee_754, B_ieee_754;

    dec_to_fp fpn_a(.A_decimal(A_decimal), .A_fractional(A_fractional), .A_scaling_factor(A_scaling_factor), .A_ieee_754(A_ieee_754));
    dec_to_fp fpn_b(.A_decimal(B_decimal), .A_fractional(B_fractional), .A_scaling_factor(B_scaling_factor), .A_ieee_754(B_ieee_754));
    fp_add_sub fpa(.A(A_ieee_754), .B(B_ieee_754), .op(1'b0), .result(result_add)); 
    fp_add_sub fps(.A(A_ieee_754), .B(B_ieee_754), .op(1'b1), .result(result_sub));
    fp_mul fpm(.A(A_ieee_754), .B(B_ieee_754), .result(result_mul));
    fp_div fpd(.A(A_ieee_754), .B(B_ieee_754), .result(result_div));
    
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
