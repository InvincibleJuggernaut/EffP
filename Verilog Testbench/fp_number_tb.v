`timescale 1s / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.12.2024 15:44:58
// Design Name: 
// Module Name: add_sub_tb
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

`include "dec_to_fp.v" 
`define N_TESTS 1000000  

module fp_number_tb();
    
    reg signed [31:0] a_d;
    reg [31:0] a_f; 
    reg [31:0] a_scaling_factor;
    wire [31:0] op;
    
    dec_to_fp fpa(a_d, a_f, a_scaling_factor, op);
    
	reg clk = 0;
	reg [127:0] testVector [`N_TESTS-1:0];
	integer mcd;
	integer test_n = 0;
	integer pass   = 0;
	integer error  = 0;
	
	real variation;
	real variation_cumulative;
	reg [31:0] Expected_result;
	
	always #5 clk = ~clk;
	
    initial  
    begin 
        variation_cumulative = 0;
        $readmemh("TestVectorFPNumbers", testVector);
        mcd = $fopen("ResultsFP.txt");
	end 

	always @(posedge clk) 
	   begin
			{Expected_result, a_d, a_f, a_scaling_factor} = testVector[test_n];
			test_n = test_n + 1'b1;
            
			#2;
			
			if (op[31:11] == Expected_result[31:11])
				begin
					pass = pass + 1'b1;
				end

			if (op[31:11] != Expected_result[31:11])
				begin
				    variation = ((Expected_result - op)/Expected_result) * 100;
                    if(variation < 0)
                    begin
                        variation = variation * (-1);
                    end
                    variation_cumulative = (variation_cumulative + variation);
					$fdisplay (mcd,"Test Failed. Expected Result = %h, Obtained result = %h, Test Number -> %d",Expected_result,op,test_n);
					error = error + 1'b1;
				end
			
			if (test_n >= `N_TESTS) 
			begin
				$fdisplay(mcd,"Completed %d tests, %d passed and %d fails.", test_n, pass, error);
				$fclose(mcd);
				variation_cumulative = (variation_cumulative / error);
				$display("%d TEST PASSED %d TESTS FAILED", pass, error);
				$display("Average variation over total test cases : %f ", variation_cumulative);
				$finish;
			end
	end
	
endmodule
