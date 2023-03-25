`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Spencer Seltzer
// 
// Create Date: 01/24/2023 05:19:40 PM
// Design Name: OTTER Program Counter
// Module Name: PC
// Target Devices: Basys3
// Description: Program counter for 32-bit OTTER micro-computer
//////////////////////////////////////////////////////////////////////////////////


module PC(
    input [31:0] JALR, //io for module
    input [31:0] BRANCH,
    input [31:0] JAL,
//    input [31:0] MTVEC,
//    input [31:0] MEPC,
    input [2:0] PC_SOURCE,
    input PC_WRITE,
    input PC_RST,
    input CLK,
    output logic [31:0] PC_ADDRESS,
    output logic [31:0] ADDR_INC_OUT
    );
    
    logic [31:0] MUX_OUT, PC_INC;
    
    always_comb //8:1 MUX with 3-bit select
        begin
            case(PC_SOURCE)
//                3'b000: MUX_OUT = MEPC;
//                3'b001: MUX_OUT = MTVEC;
                3'b010: MUX_OUT = JAL; //unconditional branch w/ offset and link
                3'b011: MUX_OUT = BRANCH; //branch instr
                3'b100: MUX_OUT = JALR; //unconditional branch and link
                3'b101: MUX_OUT = PC_INC; //pc increment to increment instr address
                3'b110: MUX_OUT = 32'hBAD; //unused mux data line input
                3'b111: MUX_OUT = 32'hBAD; //unused mux data line input
                default: MUX_OUT = PC_INC; //pc incremement to increment instr address
            endcase
        end
        
    always_ff @(posedge CLK) //PC Register
        begin
            if(PC_RST == 1'b1)
                begin
                    PC_ADDRESS <= 32'b0; //Priority reset
                end
            else if(PC_WRITE == 1'b1)
                begin
                    PC_ADDRESS <= MUX_OUT; //Data assignment to output
                end
            else
                begin
                    PC_ADDRESS <= PC_ADDRESS; //Hold value across clock cycles
                end
        end
        
            assign PC_INC = PC_ADDRESS + 4; //Increment address by 4
            assign ADDR_INC_OUT = PC_INC; //assingn increment address to addr_inc_out
            
endmodule
