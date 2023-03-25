`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Spencer Seltzer
// 
// Create Date: 02/23/2023 08:56:59 AM
// Design Name: Control Unit FSM
// Module Name: CU_FSM 
// Target Devices: Basys3
// Description: OTTER Control Unit Finite State Machine
//////////////////////////////////////////////////////////////////////////////////


module CU_FSM(
    input [6:0] ir6to0, //io for module with interrupt io removed
//    input [2:0] ir14to12,
    input RESET,
    input CLK,
    output logic PC_Write,
    output logic Reg_Write,
    output logic Mem_WE2,
    output logic Mem_RDEN1,
    output logic Mem_RDEN2,
    output logic reset
    );
    
    typedef enum{ST_INIT, ST_FETCH, ST_EXEC, ST_WB}STATES; //declare states
    STATES NS, PS;
    //state register
    always_ff @(posedge CLK) begin
        if(RESET == 1'b1)
            PS <= ST_INIT; //priority reset returns to initial state
        else
            PS <= NS; //sets present state to next state
    end
    //output controls
    always_comb begin
    //initialize outputs to zero
    reset = 1'b0;
    PC_Write = 1'b0;
    Reg_Write = 1'b0;
    Mem_WE2 = 1'b0;
    Mem_RDEN1 = 1'b0;
    Mem_RDEN2 = 1'b0;
        case(PS)
            //initial state
            ST_INIT: begin
                NS = ST_FETCH; //transitions to fetch state
                    reset = 1'b1; //sets pc reset to zero to begin at address zero
            end
            
            //fetch state
            ST_FETCH: begin
                NS = ST_EXEC; //transitions to execute state
                    Mem_RDEN1 = 1'b1; //reads instr from memory located at address specified by pc out
            end
             
            //execute state
            ST_EXEC: begin
                NS = ST_FETCH; //transitions to fetch state
                    case(ir6to0) //case on opcode to determine signals to set per instr
                        //r-type
                        7'b0110011: begin
                           PC_Write = 1'b1; //set read/write signals for r-type instr
                           Reg_Write = 1'b1;
                        end
                        //i-type
                        7'b0010011: begin
                           PC_Write = 1'b1; //set read/write signals for i-type instr
                           Reg_Write = 1'b1;
                        end
                        //i-type, jalr
                        7'b1100111: begin
                            PC_Write = 1'b1; //set read/write signals for i-type jalr instr
                            Reg_Write = 1'b1;
                        end
                        //i-type, load inst
                        7'b0000011: begin
                            NS = ST_WB; //transitions to writeback state
                            PC_Write = 1'b0; //set read/write signal for i-type load instr
                            Reg_Write = 1'b0;
                            Mem_RDEN2 = 1'b1;
                        end
                        //s-type
                        7'b0100011: begin
                            PC_Write = 1'b1; //set read/write signals for s-type instr
                            Mem_WE2 = 1'b1;
                        end
                        //b-type
                        7'b1100011: begin
                            PC_Write = 1'b1; //set read/write signal for b-type instr
                        end
                        //u-type, lui
                        7'b0110111: begin
                        PC_Write = 1'b1; //set read/write signals for u-type lui instr
                        Reg_Write = 1'b1;
                        end
                        //u-type, auipc
                        7'b0010111: begin
                        PC_Write = 1'b1; //set read/write signals for u-type auipc instr
                        Reg_Write = 1'b1;
                        end
                        //j-type
                        7'b1101111: begin
                        PC_Write = 1'b1; //set read/write signals for j-type instr
                        Reg_Write = 1'b1;
                        end
                        
                        default: NS = ST_INIT; //return to initial state
                    endcase
            end
            
            //writeback state
            ST_WB: begin
                NS = ST_FETCH; //transitions to fetch state
                PC_Write = 1'b1;
                Reg_Write = 1'b1;    
            end
            
            default: NS = ST_INIT; //return to initial state
        endcase
    end
endmodule
