`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.01.2025 15:38:58
// Design Name: 
// Module Name: fp_mul
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


module fp_mul(
    input [31:0] A,
    input [31:0] B,
    input [3:0] op, //op == 0 => addition; op == 1 => subtraction; op == 2 => multiplication
    output reg [31:0] result
);

    integer i, binary_point;
    
    reg [31:0] A_temp, B_temp;
    reg A_sign, B_sign;
    
    reg [23:0] A_mantissa;
    reg [47:0] B_mantissa;
    
    reg [7:0] A_exponent;
    reg [7:0] B_exponent;
    
    reg [7:0] result_exponent;
    reg result_sign;
    
    reg [47:0] product;
    
    always @(*)     begin
    
       binary_point = 0;
    
       A_temp = A;
       B_temp = B;
       A_sign = A_temp[31];
       B_sign = B_temp[31];
       A_exponent = A_temp[30:23];
       B_exponent = B_temp[30:23];
       
       if(A_temp == 31'b0 || B_temp == 31'b0)   begin
       
           result_sign = 1'b0;
           result_exponent = 8'b0;
           result = {result_sign, result_exponent, 23'b0};
                      
       end
       else     begin
       
           A_mantissa = {1'b1, A_temp[22:0]};
           B_mantissa = 24'b0 + {1'b1, B_temp[22:0]};
           product = 48'b0;
           
           for (i=0; i<24; i=i+1)   begin
                if(A_mantissa[0] == 1)  begin
                    product = product + B_mantissa;
                    B_mantissa = B_mantissa<<1;
                    A_mantissa = A_mantissa>>1;
                end
                else    begin
                
                    B_mantissa = B_mantissa<<1;
                    A_mantissa = A_mantissa>>1;
                end
            
            end

            for(i=0; i<48 && (product[47] != 1); i=i+1)    begin
                product = product << 1;
                binary_point = binary_point+1;
             end
     
             result_sign = A_sign ^ B_sign;
             result_exponent = A_exponent + B_exponent - binary_point - 126;
             result = {result_sign, result_exponent, product[46:24]};
            
       end
    end
      
endmodule
