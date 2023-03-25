`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Spencer Seltzer
// 
// Create Date: 02/07/2023 10:27:34 AM 
// Module Name: ALU
// Project Name: OTTER ALU
// Target Devices: Basys3
// Description: ALU for OTTER microprocessor
//////////////////////////////////////////////////////////////////////////////////


module ALU(
    input [31:0] srcA, //io for module
    input [31:0] srcB,
    input [3:0] alu_func,
    output logic [31:0] result
    );
    //MUX for all 11 alu operations
    always_comb
        begin
            case(alu_func)
            4'b0000: result = $signed(srcA) + $signed(srcB); //add
            4'b1000: result = $signed(srcA) - $signed(srcB); //subtract
            4'b0110: result = srcA | srcB; //or
            4'b0111: result = srcA & srcB; //and
            4'b0100: result = srcA ^ srcB; //xor
            4'b0101: result = srcA >> srcB[4:0]; //logical shift right
            4'b0001: result = srcA << srcB[4:0]; //logical shift left
            4'b1101: result = $signed(srcA) >>> srcB[4:0]; //arithmetic shift right
            4'b0010: result = $signed(srcA) < $signed(srcB); //set if less than
            4'b0011: result = srcA < srcB; //set if less than unsigned
            4'b1001: result = srcA; //lui copy
            default: result = $signed(srcA)+ $signed(srcB); //defaults to addition, should not be reached
            endcase
        end
    
endmodule