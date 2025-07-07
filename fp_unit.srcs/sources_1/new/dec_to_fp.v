`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.02.2025 18:40:40
// Design Name: 
// Module Name: dec_to_fp
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


//Assuming fixed point Q32.32 format
module dec_to_fp(input signed [31:0] A_decimal,
    input signed [31:0] A_fractional,
    input [31:0] A_scaling_factor,
    output reg [31:0] A_ieee_754
    );
    
    reg [63:0] intermediate_number;
    reg [63:0] fractional_part;
    reg [63:0] decimal_part;
    
    integer i;
    reg [6:0] jumps_needed;
    reg [7:0] floating_point_exponent;
    reg [9:0] index_of_leading_one;
    reg floating_point_sign;
    
    always @(*) begin
        
        index_of_leading_one = 0;
        floating_point_sign = A_decimal[31];
        
        if(floating_point_sign == 1)
        begin
            decimal_part = ((~(A_decimal) + 1) << 32);
            fractional_part = (A_fractional <<< 32) / A_scaling_factor;
            intermediate_number = decimal_part + fractional_part;
        end
        else
        begin   
            decimal_part = (A_decimal << 32);
            fractional_part = (A_fractional << 32) / A_scaling_factor;
            intermediate_number = decimal_part + fractional_part;
        end
        
//        $display("%b %b %d", A_decimal, A_fractional, A_scaling_factor);
//        $display("%b -- %b.%b",intermediate_number, intermediate_number[63:32],intermediate_number[31:0]);
        
        for(i=63; i>=0; i=i-1)
        begin
            if(intermediate_number[i] == 1 && (index_of_leading_one <= i))
            begin
                index_of_leading_one = i;
                $display("Here: %d", i);
            end
        end
        
        if(index_of_leading_one >= 32)
        begin
            jumps_needed = index_of_leading_one - 32;
            floating_point_exponent = 127 + jumps_needed;
        end
        else
        begin
            jumps_needed = 32 - index_of_leading_one;
            floating_point_exponent = 127 - jumps_needed;
        end
       
        if(A_decimal == 0 && A_fractional == 0)
            A_ieee_754 = 32'd0;
        else
            A_ieee_754 = {floating_point_sign, floating_point_exponent, intermediate_number[(index_of_leading_one - 1)-:23]};
            
//        $display("%b", A_ieee_754);
           
    end
endmodule