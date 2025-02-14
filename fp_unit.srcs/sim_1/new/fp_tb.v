`timescale 1ns / 1ps
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

module div_tb();
    
reg [31:0] a;
reg [31:0] b; 
reg [3:0] operation;
wire [31:0] op;

fp_div fpd(.A(a), .B(b), .op(operation), .result(op));

    initial begin 
    
    a = 32'hc763dc00; //-58332
    b = 32'h4b38f47c; //12121212
    #50; //-207.7969553589796
    
    
    a = 32'h42860000; //67 
    b = 32'h40e00000; //7
    #50; 
    
    a = 32'h40e00000; //7 
    b = 32'h40000000; //2
    #50; 
    
        a = 32'h42c80000; //100
    b = 32'h41200000; //10
    #50; 
    
    a = 32'hd07fffff; //-1.7179868e10
    b = 32'hdc7fffff; //-2.8823036e17
    #50; //5.960464400766109e-8
    
    a = 32'h43fa0000; //500    
    b = 32'h3e4ccccd; //0.2
    #50; 

    a = 32'h43fa0000; //500    
    b = 32'h3fba0a23; //1.4534344
    #50; 
    
    end
    
endmodule
    

//module mul_tb();
    
//reg [31:0] a;
//reg [31:0] b; 
//reg [3:0] operation;
//wire [31:0] op;

//fp_mul fpm(a, b, operation, op);

//    initial begin 
    
//    a = 32'h40e00000; //7 
//    b = 32'h40000000; //2
//    operation = 3'b1;
//    #50; 
    
//    a = 32'hd07fffff; //-1.7179868e10
//    b = 32'hdc7fffff; //-2.8823036e17
//    operation = 3'b1;
//    #50; 
        
//    a = 32'h3b03126f; //0.002
//    b = 32'h43fa0000; //500
//    operation = 3'b1;
//    #50; 
    
//    a = 32'hb83ea191; //-0.00004545
//    b = 32'hb9aecc30; //-0.00033339999
//    operation = 3'b1;
//    #50; 
     
//    a = 32'h42340000; //45
//    b = 32'h4282a8f6; //65.33
//    operation = 3'b1;
//    #50; 
    
//    a = 32'h00000000; //0
//    b = 32'h00000000; //0
//    operation = 3'b1;
//    #50;
    
//    a = 32'hc231c28f; //-44.44
//    b = 32'hc231c28f; //-44.44
//    operation = 3'b1;
//    #50;
    
//    a = 32'hc231c28f; //-44.44
//    b = 32'h4231c28f; //44.44
//    operation = 3'b1;
//    #50;
    
//    a = 32'h461b0ce5; //9923.2234212
//    b = 32'h3eaa276b; //0.332332
//    operation = 3'b1;
//    #50;
    
//    end
    
//endmodule


//module add_sub_tb();
    
//    reg [31:0] a;
//    reg [31:0] b; 
//    reg [3:0] operation;
//    wire [31:0] op;
    
//    fp_add_sub fpa(a, b, operation, op);
    
//        initial begin 
        
        
//        a = 32'h440f4000; //573
//        b = 32'hc40f4000; //-573
//        operation = 4'b0;
//        #50;  
        
//        a = 32'hc40f4000; //573
//        b = 32'h440f4000; //573
//        operation = 4'b1;
//        #50;  
        
//        a = 32'h440f4000; //573
//        b = 32'hc40f4000; //-573
//        operation = 3'b0;
//        #50;  
        
//        a = 32'hc40f4000; //-573
//        b = 32'h440f4000; //573
//        operation = 3'b0;
//        #50;

//            end 

//endmodule

