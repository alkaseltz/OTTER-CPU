`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Spencer Seltzer
// 
// Create Date: 02/09/2023 11:26:19 AM
// Module Name: IMM_GEN
// Project Name: OTTER IMMEDIATE GENERATOR
// Target Devices: Basys3
// Description: Immediate Generator for OTTER microprocessor
//////////////////////////////////////////////////////////////////////////////////


   module IMM_GEN(
    input [24:0] addr_in, //io for module
    output logic [31:0] u_type,
    output logic [31:0] i_type,
    output logic [31:0] s_type,
    output logic [31:0] b_type,
    output logic [31:0] j_type
    );
    //simultaneous immediate generation
    assign u_type = {addr_in[24:5], {12{1'b0}}}; //u-type immediate generation
    assign i_type = {{21{addr_in[24]}}, addr_in[23:18], addr_in[17:13]}; //i-type immediate generation
    assign s_type = {{21{addr_in[24]}}, addr_in[23:18], addr_in[4:0]}; //s-type immediate generation
    assign b_type = {{20{addr_in[24]}}, addr_in[0], addr_in[23:18], addr_in[4:1], 1'b0}; //b-type immediate generation
    assign j_type = {{12{addr_in[24]}}, addr_in[12:5], addr_in[13], addr_in[23:14], 1'b0};//j-type immediate generation
    
endmodule
