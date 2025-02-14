`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.12.2024 15:14:49
// Design Name: 
// Module Name: fp_add_sub
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


module fp_add_sub(
    input [31:0] A,
    input [31:0] B,
    input op, //op == 0 => addition; op == 1 => subtraction
    output reg [31:0] result,
    output reg overflow,
    output reg underflow,
    output reg isNaN
);

    integer i, decimal_point;
    
    reg [31:0] A_temp, B_temp;
    reg A_sign, B_sign;
    reg [23:0] A_mantissa;
    reg [23:0] B_mantissa;
    reg [7:0] A_exponent;
    reg [7:0] B_exponent;
    
    reg [7:0] Exponent_difference;
    
    reg [24:0] temp_result_mantissa;
    reg [7:0] temp_larger_exponent;
    
    reg [22:0] result_mantissa;
    reg [7:0] result_exponent;
    reg result_sign;

    always @(*) begin
    
    decimal_point = 0;
    
    
    if(A[31] != B[31])    begin
        if(B[31] == 1)     begin   
            A_temp = A;
            B_temp = B;
        end
        else    begin
            A_temp = B;
            B_temp = A;
        end
        
       A_sign = A_temp[31];
       B_sign = B_temp[31];
       A_exponent = A_temp[30:23];
       B_exponent = B_temp[30:23];
       A_mantissa = {1'b1, A_temp[22:0]};
       B_mantissa = {1'b1, B_temp[22:0]};
       
       $display("MANTISSAS A_MANTISSA:%b, B_MANTISSA:%b", A_mantissa, B_mantissa);
       
       if(A_exponent == B_exponent && A_mantissa == B_mantissa && op == 0)     begin
            result_mantissa = 23'b0;
            result_exponent = 8'b0;
            result_sign = 1'b0;
       end
     
       else if(A_exponent >= B_exponent)  begin
            Exponent_difference = A_exponent - B_exponent;
            temp_larger_exponent = A_exponent;

            for (i=0; i<Exponent_difference; i=i+1)  begin
                B_mantissa = B_mantissa >> 1; //shifting bigger number to left is losing the MSBs
            end 
          
            if(op == 0)  begin

                if(A_mantissa >= B_mantissa && A[31] == 0)    begin
                    result_sign = 1'b0;
                    temp_result_mantissa = A_mantissa - B_mantissa;
                    $display("STAGE 1");
                end
                else if(A_mantissa >= B_mantissa && A[31] == 1)    begin
                    result_sign = 1'b0; //1'b0;
                    temp_result_mantissa = A_mantissa - B_mantissa;
                    $display("STAGE 2");
                end
                else if(A_mantissa < B_mantissa && A[31] == 1)    begin
                    result_sign = 1'b1;
                    temp_result_mantissa = B_mantissa - A_mantissa;
                    $display("STAGE 3");
                end
                else if(A_mantissa < B_mantissa && A[31] == 0)    begin
                    result_sign = 1'b1;
                    temp_result_mantissa = B_mantissa - A_mantissa;
                    $display("STAGE 4");
                end 

                if(temp_result_mantissa[24] == 1)   begin
                      
                        for(i=0; i<24 && (temp_result_mantissa[24] != 1); i=i+1)    begin
                               temp_result_mantissa = temp_result_mantissa << 1;
                               decimal_point = decimal_point+1;
                        end
                        result_mantissa = temp_result_mantissa[23:1];
                        result_exponent = temp_larger_exponent-decimal_point+1;
                     end
                     else   begin
                        for(i=0; i<24 && (temp_result_mantissa[23] != 1); i=i+1)    begin
                                temp_result_mantissa = temp_result_mantissa << 1;
                                decimal_point = decimal_point+1;
                         end 
                         result_mantissa = temp_result_mantissa[22:0];
                         result_exponent = temp_larger_exponent-decimal_point;
                     end

    
            end 
            
            else if(op == 1)  begin
                               
               temp_result_mantissa = A_mantissa + B_mantissa;
               $display("STAGE 5");
                  if(A[31] == 1)   begin
                       result_sign = 1'b1;
                  end
                  else     begin
                       result_sign = 1'b0;
                  end

                    if(temp_result_mantissa[24] == 1)   begin
                      
                        for(i=0; i<24 && (temp_result_mantissa[24] != 1); i=i+1)    begin
                               temp_result_mantissa = temp_result_mantissa << 1;
                               decimal_point = decimal_point+1;
                        end
                        result_mantissa = temp_result_mantissa[23:1];
                        result_exponent = temp_larger_exponent-decimal_point+1;
                     end
                     else   begin
                        for(i=0; i<24 && (temp_result_mantissa[23] != 1); i=i+1)    begin
                                temp_result_mantissa = temp_result_mantissa << 1;
                                decimal_point = decimal_point+1;
                         end 
                         result_mantissa = temp_result_mantissa[22:0];
                         result_exponent = temp_larger_exponent-decimal_point;
                     end

           end    
     
       end
       else     begin
            Exponent_difference = B_exponent - A_exponent;
            temp_larger_exponent = B_exponent;
            
            for (i=0; i<Exponent_difference; i=i+1)  begin
               A_mantissa = A_mantissa >> 1;
            end
            
           if(op == 0)  begin
            
                if(A_mantissa >= B_mantissa)    begin
                    result_sign = 1'b1;
                    temp_result_mantissa = A_mantissa - B_mantissa;
                    $display("STAGE 6");
                end
                else    begin
                    result_sign = 1'b1;
                    temp_result_mantissa = B_mantissa - A_mantissa;
                    $display("STAGE 7");
                end
                 if(temp_result_mantissa[24] == 1)   begin
                      
                        for(i=0; i<24 && (temp_result_mantissa[24] != 1); i=i+1)    begin
                               temp_result_mantissa = temp_result_mantissa << 1;
                               decimal_point = decimal_point+1;
                        end
                        result_mantissa = temp_result_mantissa[23:1];
                        result_exponent = temp_larger_exponent-decimal_point+1;
                     end
                     else   begin
                        for(i=0; i<24 && (temp_result_mantissa[23] != 1); i=i+1)    begin
                                temp_result_mantissa = temp_result_mantissa << 1;
                                decimal_point = decimal_point+1;
                         end 
                         result_mantissa = temp_result_mantissa[22:0];
                         result_exponent = temp_larger_exponent-decimal_point;
                     end
          end
          
          else if(op == 1)  begin
                             
             temp_result_mantissa = A_mantissa + B_mantissa;
             $display("STAGE 8");
                if(A[31] == 1)   begin
                     result_sign = 1'b1;
                end
                else     begin
                     result_sign = 1'b0;
                end

                if(temp_result_mantissa[24] == 1)   begin
                      
                        for(i=0; i<24 && (temp_result_mantissa[24] != 1); i=i+1)    begin
                               temp_result_mantissa = temp_result_mantissa << 1;
                               decimal_point = decimal_point+1;
                        end
                        result_mantissa = temp_result_mantissa[23:1];
                        result_exponent = temp_larger_exponent-decimal_point+1;
                     end
                     else   begin
                        for(i=0; i<24 && (temp_result_mantissa[23] != 1); i=i+1)    begin
                                temp_result_mantissa = temp_result_mantissa << 1;
                                decimal_point = decimal_point+1;
                         end 
                         result_mantissa = temp_result_mantissa[22:0];
                         result_exponent = temp_larger_exponent-decimal_point;
                     end
         end 
         
         
         end
       
    end
    
    
    
    else        begin

        A_temp = A;
        B_temp = B;
        
           A_sign = A_temp[31];
           B_sign = B_temp[31];
           A_exponent = A_temp[30:23];
           B_exponent = B_temp[30:23];
           A_mantissa = {1'b1, A_temp[22:0]};
           B_mantissa = {1'b1, B_temp[22:0]};
           
           $display("MANTISSAS A_MANTISSA:%b, B_MANTISSA:%b", A_mantissa, B_mantissa);
                  
           if(A_exponent >= B_exponent)  begin
                Exponent_difference = A_exponent - B_exponent;
                temp_larger_exponent = A_exponent;
              
                for (i=0; i<Exponent_difference; i=i+1)  begin
                    B_mantissa = B_mantissa >> 1; //shifting bigger number to left is losing the MSBs
                end 
                
                            
                if(op == 0)  begin
                    
                    temp_result_mantissa = A_mantissa + B_mantissa;
                    $display("TEMP_RES_MANTISSA: %b",temp_result_mantissa); 
                    $display("STAGE 9");
                    if(A[31] == 1)   begin
                       result_sign = 1'b1;
                      end
                      else     begin
                           result_sign = 1'b0;
                      end

                    if(temp_result_mantissa[24] == 1)   begin
                      
                        for(i=0; i<24 && (temp_result_mantissa[24] != 1); i=i+1)    begin
                               temp_result_mantissa = temp_result_mantissa << 1;
                               decimal_point = decimal_point+1;
                        end
                        result_mantissa = temp_result_mantissa[23:1];
                        result_exponent = temp_larger_exponent-decimal_point+1;
                     end
                     else   begin
                        for(i=0; i<24 && (temp_result_mantissa[23] != 1); i=i+1)    begin
                                temp_result_mantissa = temp_result_mantissa << 1;
                                decimal_point = decimal_point+1;
                         end 
                         result_mantissa = temp_result_mantissa[22:0];
                         result_exponent = temp_larger_exponent-decimal_point;
                     end
                     $display("TAFTER SHIFTING2: %b %b",temp_result_mantissa, decimal_point); 
                    
                end 
                
                else if(op == 1)  begin
                                   
                if(A_mantissa >= B_mantissa && A[31] == 0)    begin
                    result_sign = 1'b0;
                    temp_result_mantissa = A_mantissa - B_mantissa;
                    $display("STAGE 10");
                end
                else if(A_mantissa >= B_mantissa && A[31] == 1)    begin
                    result_sign = 1'b1;
                    temp_result_mantissa = A_mantissa - B_mantissa;
                    $display("STAGE 11");
                end
                else if(A_mantissa < B_mantissa && A[31] == 1)    begin
                    result_sign = 1'b0;
                    temp_result_mantissa = B_mantissa - A_mantissa;
                    $display("STAGE 12");
                end
                else if(A_mantissa < B_mantissa && A[31] == 0)    begin
                    result_sign = 1'b1;
                    temp_result_mantissa = B_mantissa - A_mantissa;
                    $display("STAGE 13");
                end 

                   if(temp_result_mantissa[24] == 1)   begin
                      
                        for(i=0; i<24 && (temp_result_mantissa[24] != 1); i=i+1)    begin
                               temp_result_mantissa = temp_result_mantissa << 1;
                               decimal_point = decimal_point+1;
                        end
                        result_mantissa = temp_result_mantissa[23:1];
                        result_exponent = temp_larger_exponent-decimal_point+1;
                     end
                     else   begin
                        for(i=0; i<24 && (temp_result_mantissa[23] != 1); i=i+1)    begin
                                temp_result_mantissa = temp_result_mantissa << 1;
                                decimal_point = decimal_point+1;
                         end 
                         result_mantissa = temp_result_mantissa[22:0];
                         result_exponent = temp_larger_exponent-decimal_point;
                     end
               end    
         
           end
           else     begin
                Exponent_difference = B_exponent - A_exponent;
                temp_larger_exponent = B_exponent;
                
                for (i=0; i<Exponent_difference; i=i+1)  begin
                   A_mantissa = A_mantissa >> 1;
                end
                
               if(op == 0)  begin
                                    
                    temp_result_mantissa = A_mantissa + B_mantissa;
                    $display("TEMP_RES_MANTISSA: %b",temp_result_mantissa); 
                    $display("STAGE 14");
                    if(A[31] == 1)   begin
                       result_sign = 1'b1;
                      end
                      else     begin
                           result_sign = 1'b0;
                      end
                    if(temp_result_mantissa[24] == 1)   begin
                      
                        for(i=0; i<24 && (temp_result_mantissa[24] != 1); i=i+1)    begin
                               temp_result_mantissa = temp_result_mantissa << 1;
                               decimal_point = decimal_point+1;
                        end
                        result_mantissa = temp_result_mantissa[23:1];
                        result_exponent = temp_larger_exponent-decimal_point+1;
                     end
                     else   begin
                        for(i=0; i<24 && (temp_result_mantissa[23] != 1); i=i+1)    begin
                                temp_result_mantissa = temp_result_mantissa << 1;
                                decimal_point = decimal_point+1;
                         end 
                         result_mantissa = temp_result_mantissa[22:0];
                         result_exponent = temp_larger_exponent-decimal_point;
                     end
                    
                    $display("TAFTER SHIFTING2: %b %b",temp_result_mantissa, decimal_point);
                end 
              
              else if(op == 1)  begin
                                                   
                if(A_mantissa >= B_mantissa && A[31] == 0)    begin
                      result_sign = 1'b0;
                      temp_result_mantissa = A_mantissa - B_mantissa;
                      $display("STAGE 15");
                  end
                  else if(A_mantissa >= B_mantissa && A[31] == 1)    begin
                      result_sign = 1'b1;
                      temp_result_mantissa = A_mantissa - B_mantissa;
                      $display("STAGE 16");
                  end
                  else if(A_mantissa < B_mantissa && A[31] == 1)    begin
                      result_sign = 1'b0;
                      temp_result_mantissa = B_mantissa - A_mantissa;
                      $display("STAGE 17");
                  end
                  else if(A_mantissa < B_mantissa && A[31] == 0)    begin
                      result_sign = 1'b1;
                      temp_result_mantissa = B_mantissa - A_mantissa;
                      $display("STAGE 18");
                  end 
                  
                  if(temp_result_mantissa[24] == 1)   begin
                                        
                                          for(i=0; i<24 && (temp_result_mantissa[24] != 1); i=i+1)    begin
                                                 temp_result_mantissa = temp_result_mantissa << 1;
                                                 decimal_point = decimal_point+1;
                                          end
                                          result_mantissa = temp_result_mantissa[23:1];
                                          result_exponent = temp_larger_exponent-decimal_point+1;
                                       end
                                       else   begin
                                          for(i=0; i<24 && (temp_result_mantissa[23] != 1); i=i+1)    begin
                                                  temp_result_mantissa = temp_result_mantissa << 1;
                                                  decimal_point = decimal_point+1;
                                           end 
                                           result_mantissa = temp_result_mantissa[22:0];
                                           result_exponent = temp_larger_exponent-decimal_point;
                                       end

               end 
             
             
             end
 
    end
            result = {result_sign, result_exponent, result_mantissa};
    end

endmodule
