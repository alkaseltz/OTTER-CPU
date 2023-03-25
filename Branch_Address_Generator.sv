`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Spencer Seltzer
// 
// Create Date: 02/09/2023 12:49:27 PM
// Module Name: Branch_Address_Generator
// Project Name: OTTER BAG
// Target Devices: Basys3
// Description: Branch Address Generator for OTTER microprocessor
//////////////////////////////////////////////////////////////////////////////////


module Branch_Address_Generator(
    input [31:0] j_type, //io for module
    input [31:0] b_type,
    input [31:0] i_type,
    input [31:0] RS1,
    input [31:0] PC,
    output logic [31:0] jalr,
    output logic [31:0] branch,
    output logic [31:0] jal
    );
    //simultaneous branch address generation
    assign jalr = RS1 + i_type; //creates branch address for jalr instr by adding RS1 to i-type immediate
    assign branch = PC + b_type; //creates branch address for branch instr by adding PC to b-type immediate
    assign jal = PC + j_type; //creates branch address for jal instr by adding PC to j-type immediate
    
endmodule
