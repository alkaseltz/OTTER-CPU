`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Spencer Seltzer
// 
// Create Date: 02/09/2023 01:08:13 PM
// Module Name: Branch_Cond_Generator
// Project Name: OTTER BCG
// Target Devices: Basys3
// Description: Branch Condition Generator for OTTER microprocessor
//////////////////////////////////////////////////////////////////////////////////


module Branch_Cond_Generator(
    input [31:0] RS1, //io for module
    input [31:0] RS2,
    output br_eq,
    output br_lt,
    output br_ltu
    );
    //simultaneous branch condition generation
    assign br_eq = RS1 == RS2; //set br_eq output to logic level high when RS1 and RS2 are equal
    assign br_lt = $signed(RS1) < $signed(RS2); //set br_lt output to logic level high when RS1 < RS2 (treated as signed)
    assign br_ltu = RS1 < RS2; //set br_ltu to logic level high when RS1 < RS2 (treated as unsigned)
    
endmodule
