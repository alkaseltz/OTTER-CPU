`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Spencer Seltzer
// 
// Create Date: 02/23/2023 09:11:41 AM
// Design Name: Control Unit Decoder
// Module Name: CU_DCDR
// Target Devices: Basys3
// Description: OTTER Control Unit Decoder
//////////////////////////////////////////////////////////////////////////////////


module CU_DCDR(
    input [6:0] ir6to0, //io for module with interrupt io removed
    input [2:0] ir14to12,
    input ir30,
    input br_eq,
    input br_lt,
    input br_ltu,
    output logic [3:0] alu_fun,
    output logic alu_srcA,
    output logic [1:0] alu_srcB,
    output logic [2:0] PC_SOURCE,
    output logic [1:0] rf_wr_sel
    );
    
    always_comb begin
    //initialize outputs to zero
        alu_fun = 3'b0;
        alu_srcA = 1'b0;
        alu_srcB = 2'b0;
        PC_SOURCE = 3'b0;
        rf_wr_sel = 2'b0;
        
    case(ir6to0) //case on opcode to determine signals to set per instr
        //r-type
        7'b0110011: begin
            rf_wr_sel = 2'b11; //sets sel to 3 for all r-type inst
            case(ir14to12) //case on fun3 bits to determine signals to set for instr with shared opcode
                3'b000: begin
                    case(ir30) //case on 30th bit to determine signals to set for instr with shared fun3 bits
                        1'b0: alu_fun = 4'b0000; //sets alu_fun to add
                        1'b1: alu_fun = 4'b1000; //sets alu_fun to subtract
                        default: alu_fun = 4'b1111; //default (should not be reached)
                    endcase
                end
                
                3'b001: begin
                    alu_fun = 4'b0001; //sets alu_fun to logical shift left
                end
                
                3'b010: begin
                    alu_fun = 4'b0010; //sets alu_fun to set if less than
                end
                
                3'b011: begin
                    alu_fun = 4'b0011; //sets alu_fun to set if less than unsigned
                end
                
                3'b100: begin
                    alu_fun = 4'b0100; //sets alu_fun to xor
                end
                
                3'b101: begin
                     case(ir30) //case on 30th bit to determine signals to set for instr with shared fun3 bits
                        1'b0: alu_fun = 4'b0101; //sets alu_fun to logical shift right
                        1'b1: alu_fun = 4'b1101; //sets alu_fun to arithmetic shift right
                        default: alu_fun = 4'b1111; //default (should not be reached)
                    endcase
                end
                
                3'b110: begin
                    alu_fun = 4'b0110; //sets alu_fun to or
                end
                
                3'b111: begin
                    alu_fun = 4'b0111; //sets alu_fun to and
                end
                
                default: alu_fun = 4'b1111; //default (should not be reached)
            endcase
        end
        //i-type
        7'b0010011: begin
            alu_srcB = 2'b01; //sets alu_srcB for most i-type inst
            rf_wr_sel = 2'b11; //sets sel to 3 for most i-type inst
            case(ir14to12) //case on fun3 bits to determine signals to set for instr with shared opcode
                3'b000: begin
                    alu_fun = 4'b0000; //sets alu_fun to add
                end
                
                3'b001: begin
                    alu_fun = 4'b0001; //sets alu_fun to logical shift left
                end
                
                3'b010: begin
                    alu_fun = 4'b0010; //sets alu_fun to set if less than
                end
                
                3'b011: begin
                    alu_fun = 4'b0011; //sets alu_fun to set if less than unsigned
                end
                
                3'b100: begin
                    alu_fun = 4'b0100; //sets alu_fun to xor
                end
                
                3'b101: begin
                    case(ir30) //case on 30th bit to determine signals to set for instr with shared fun3 bits
                        1'b0: alu_fun = 4'b0101; //sets alu_fun to logical shift right
                        1'b1: alu_fun = 4'b1101; //sets alu_fun to arithmetic shift right
                        default: alu_fun = 4'b1111; //default (should not be reached)
                    endcase
                end
                
                3'b110: begin
                    alu_fun = 4'b0110; //sets alu_fun to or
                end
                
                3'b111: begin
                    alu_fun = 4'b0111; //sets alu_fun to and
                end
                
                default: alu_fun = 4'b1111; //default (should not be reached)
            endcase
        end
        //i-type, jalr
        7'b1100111: begin
            PC_SOURCE = 3'b100; //sets pc_source to jalr (4)
        end
        //i-type, load inst
        7'b0000011: begin
            alu_srcB = 2'b01; //sets alu_srcB to (1)
            rf_wr_sel = 2'b10; //sets sel to pc_address_inc (2)
        end
        //s-type
        7'b0100011: begin
            alu_srcB = 2'b10; //sets alu_srcB to s-type imm (2)
        end
        //b-type
        7'b1100011: begin
            case(ir14to12) //case on fun3 bits to determine signals to set for instr with shared opcode
                3'b000: begin
                    if(br_eq == 1'b1) //handles branch if equal inst
                        PC_SOURCE = 3'b011; //sets pc_source to branch (3)
                    else
                        PC_SOURCE = 3'b101; //sets pc_source to pc_address_inc (5)
                end
                
                3'b101: begin
                    if(br_lt == 1'b0) //handles branch if greater than or equal inst (signed)
                        PC_SOURCE = 3'b011; //sets pc_source to branch (3)
                    else
                        PC_SOURCE = 3'b101; //sets pc_source to pc_address_inc (5)
                end
                
                3'b111: begin
                    if(br_ltu == 1'b0) //handles branch if greater than or equan inst (unsigned)
                        PC_SOURCE = 3'b011; //sets pc_source to branch (3)
                    else
                        PC_SOURCE = 3'b101; //sets pc_source to pc_address_inc (5)
                end
                
                3'b100: begin
                    if(br_lt == 1'b1) //handles branch if less than inst (signed)
                        PC_SOURCE = 3'b011; //sets pc_source to branch (3)
                    else
                        PC_SOURCE = 3'b101; //sets pc_source to pc_address_inc (5)
                end
                
                3'b110: begin
                    if(br_ltu == 1'b1) //handles branch if less than inst (unsigned)
                        PC_SOURCE = 3'b011; //sets pc_source to branch (3)
                    else
                        PC_SOURCE = 3'b101; //sets pc_source to pc_address_inc (5)
                end
                
                3'b001: begin
                    if(br_eq == 1'b0) //handles branch if not equal to zero inst
                        PC_SOURCE = 3'b011; //sets pc_source to branch (3)
                    else
                        PC_SOURCE = 3'b101; //sets pc_source to pc_address_inc (5)
                end
                
                default: PC_SOURCE = 3'b101; //default (should not be reached)
            endcase
        end
        //u-type, lui
        7'b0110111: begin
            alu_fun = 4'b1001; //sets alu_fun to lui copy
            rf_wr_sel = 2'b11; //sets sel to 3
            alu_srcA = 1'b1; //sets alu_srcA to u-type (1)
        end
        //u-type, auipc
        7'b0010111: begin
            alu_srcB = 2'b11; //sets alu_srcB to pc_address (3)
            rf_wr_sel = 2'b11; //set sel to 3
            alu_srcA = 1'b1; //sets alu_srcA to u-type (1)
        end
        //j-type
        7'b1101111: begin
            PC_SOURCE = 3'b010; //sets pc_source to jal (2)
        end
        
        default: begin //default (should not be reached), sets all outputs to (1)
            alu_fun = 4'b0001;
            alu_srcA = 1'b1;
            alu_srcB = 2'b01;
            PC_SOURCE = 3'b001;
            rf_wr_sel = 2'b01;
        end
    endcase
    end
    
endmodule
