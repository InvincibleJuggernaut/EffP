`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.01.2025 09:34:29
// Design Name: 
// Module Name: fp_div
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


module fp_div(
    input [31:0] A,
    input [31:0] B,
    input [3:0] op, //op == 0 => addition; op == 1 => subtraction; op == 2 => multiplication; op == 3 => division
    output reg [31:0] result
);

    integer i, leading_ones;
    
    reg [31:0] A_temp, B_temp;
    reg A_sign, B_sign;
    
    reg [23:0] A_mantissa;
    reg [47:0] B_mantissa;
    
    reg [7:0] A_exponent;
    reg [7:0] B_exponent;
    
    reg [7:0] result_exponent;
    reg result_sign;
    
    reg [48:0] remainder;
    reg [47:0] divisor;
    reg [23:0] quotient;
    reg [23:0] temp_quotient;
    
    reg [48:0] fractional_remainder;
    reg [47:0] fractional_divisor;
    reg [23:0] fractional_quotient;
    //reg [23:0] temp_quotient;
    
    reg [71:0] temporary_result;
    reg [22:0] quotient_remainder;
    
    reg [6:0] excess;
    
    reg [47:0] mant_a;
    reg [47:0] mant_b;
       
   always @(*)
   begin
       A_temp = A;
       B_temp = B;
       A_sign = A_temp[31];
       B_sign = B_temp[31];
       A_exponent = A_temp[30:23];
       B_exponent = B_temp[30:23];
       
       leading_ones = 0;

//       if(A_temp[22:0] == 23'b0 || B_temp[22:0] == 23'b0)   begin
       
////           result_sign = 1'b0;
////           result_exponent = 8'b0;
////           result = {result_sign, result_exponent, 23'b0};
           
//       end
       //else     begin
       
       A_mantissa = {1'b1, A_temp[22:0]};
       B_mantissa = {1'b1, B_temp[22:0]};
       
       
          //$display("LETSS GOGOGOGOG");
          //$display("A_temp: %b  ---- B_temp: %b", A_temp, B_temp);
          //$display("A_man: %b B_man: %b", A_mantissa, B_mantissa);
          //$display("A_exp: %d B_exp: %d", A_exponent, B_exponent);
           for(i=0; i<24 && (A_mantissa[0] != 1); i=i+1)    begin
                A_mantissa = A_mantissa >> 1;
           end
            
           for(i=0; i<24 && (B_mantissa[0] != 1 && (23-i)!=(B_exponent-127)); i=i+1)    begin
                B_mantissa = B_mantissa >> 1;
           end

           remainder = 49'b0 + A_mantissa;
           divisor = {(B_mantissa), 24'b0};
           quotient = 24'b0;
           
           //$display("REMAINDER:%b, DIVISOR: %b, QUOTIENT: %b", remainder, divisor, quotient);
           mant_a = {24'b0,1'b1,A[22:0]} ;
           mant_b = {24'b0,1'b1,B[22:0]} ;
           
           for (i = 0; i < 24; i = i + 1) begin 
                quotient = quotient << 1; 
                if (mant_a >= mant_b) begin 
                    mant_a = mant_a - mant_b; 
                    quotient[0] = 1; 
                end 
                mant_a = mant_a << 1; 
           end 
//           for (i=0; i<25; i=i+1)   begin
//                remainder = remainder - divisor;
//                if(remainder[47] == 1)  begin
//                    remainder = remainder + divisor;
//                    quotient = quotient<<1;
//                    divisor = divisor>>1;
//                end
//                else    begin
//                    quotient = (quotient<<1) | 1'b1;
//                    divisor = divisor>>1;
//                end
            
//            end

            fractional_remainder = (49'b0 + remainder << 24);
            fractional_divisor = {(B_mantissa), 24'b0};
            fractional_quotient = 24'b0;
            //Shifting the remainder and another iteration of division for finding fractional part
            for (i=0; i<25; i=i+1)   begin
                fractional_remainder = fractional_remainder - fractional_divisor;
                if(fractional_remainder[47] == 1)  begin
                    fractional_remainder = fractional_remainder + fractional_divisor;
                    fractional_quotient = fractional_quotient<<1;
                    fractional_divisor = fractional_divisor>>1;
                end
                else    begin
                    fractional_quotient = (fractional_quotient<<1) | 1'b1;
                    fractional_divisor = fractional_divisor>>1;
                end
            
            end
           
            //$display("REMAINDER:%b, DIVISOR: %b, QUOTIENT: %b", remainder, divisor, quotient);

            for(i=0; i<24 && (fractional_quotient[23] != 1); i=i+1)    begin
                fractional_quotient = fractional_quotient << 1;
             end
             
             //$display("FRACTIONAL PART: %b", fractional_quotient);

             temporary_result = {quotient, fractional_quotient};
             //$display("temporary_result: %b", temporary_result);
             temp_quotient = quotient;
             for(i=0; i<24 && (temp_quotient[23] != 1); i=i+1)    begin
                temp_quotient = temp_quotient << 1;
                leading_ones = leading_ones + 1;
             end
             
             for(i=0; i<72 && (temporary_result[71] != 1); i=i+1)    begin
                temporary_result = temporary_result << 1;
             end

        
     //$display("temporary_result: %b  QUOTIENT: %b REMAINDER:%b", temporary_result, temp_quotient, remainder);
     //$display("QUOT: %b  -- LEADING ONES: %d", temp_quotient, leading_ones);
     result_sign = A_sign ^ B_sign;
     if(A_exponent < B_exponent)   begin
        //$display("WE WENT THROUGH 1st");
        result_exponent = A_exponent - B_exponent + 8'd127;
        //excess = 0;
     end
     else if(A_exponent - B_exponent >= (24-leading_ones))    begin
        //$display("WE WENT THROUGH 2nd");
        excess = A_exponent - B_exponent - (24-leading_ones) + 1;
        result_exponent = A_exponent - B_exponent + 8'd127 - excess;
     end
     else   begin
        //$display("WE WENT THROUGH 3rd");
        excess = leading_ones;
        result_exponent = A_exponent - B_exponent + 8'd127 - excess;
     end
     
     result = {result_sign, result_exponent, temporary_result[70:48]};
      
       end
    
endmodule
