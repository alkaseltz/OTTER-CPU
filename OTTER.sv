`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Spencer Seltzer
// 
// Create Date: 02/23/2023 09:46:05 AM
// Design Name: OTTER Top Level
// Module Name: OTTER
// Target Devices: Basys3
// Description: Top Level Design for OTTER MCU
//////////////////////////////////////////////////////////////////////////////////


module OTTER(
    input RST,
    input [31:0] IOBUSIN,
    input CLK,
    output IOBUSWR,
    output [31:0] IOBUSOUT,
    output [31:0] IOBUSADDR
    );
     //Declare all internal logic signals (wires)
     logic [31:0] BAGtoPCMUX_jalr, BAGtoPCMUX_branch, BAGtoPCMUX_jal, PCOUT, PCINC, RS1, RS2, u_type, i_type, s_type, b_type, j_type, ALUOUT,
                  srcAMUXOUT, srcBMUXOUT, regMUXOUT, DOUT1, DOUT2;
     logic [13:0] PCOUT15to2;
     logic [24:0] DOUT31to7;
     logic [6:0] DOUT16to0;
     logic [4:0] DOUT119to15, DOUT124to20, DOUT111to7;
     logic [3:0] alu_func;
     logic [2:0] DOUT114to12, pcSource;
     logic [1:0] DOUT13to12, alu_srcBsel, regMUXsel;
     logic DOUT114, DOUT130, pcWrite, regWrite, memWE2, memRDEN1, memRDEN2, reset, alu_srcAsel, br_eq, br_lt, br_ltu;
     
     assign PCOUT15to2 = PCOUT[15:2];
     assign DOUT31to7 = DOUT1[31:7];
     assign DOUT119to15 = DOUT1[19:15];
     assign DOUT124to20 = DOUT1[24:20];
     assign DOUT111to7 = DOUT1[11:7];
     assign DOUT13to12 = DOUT1[13:12];
     assign DOUT114 = DOUT1[14];
     assign DOUT130 = DOUT1[30];
     assign DOUT114to12 = DOUT1[14:12];
     assign DOUT16to0 = DOUT1[6:0];
     assign IOBUSADDR = ALUOUT;
     assign IOBUSOUT = RS2;
     //MUXES (REG File, ALU srcA, ALU srcB)
     always_comb begin
        case(regMUXsel)
            2'b00: regMUXOUT = PCINC;
            2'b01: regMUXOUT = 32'hBAD;
            2'b10: regMUXOUT = DOUT2;
            2'b11: regMUXOUT = ALUOUT;
            default: regMUXOUT = 32'hBAD;
        endcase
        
        case(alu_srcAsel)
            1'b0: srcAMUXOUT = RS1;
            1'b1: srcAMUXOUT = u_type;
            default: srcAMUXOUT = 32'hBAD;
        endcase
            
        case(alu_srcBsel)
            2'b00: srcBMUXOUT = RS2;
            2'b01: srcBMUXOUT = i_type;
            2'b10: srcBMUXOUT = s_type;
            2'b11: srcBMUXOUT = PCOUT;
            default: regMUXOUT = 32'hBAD;
        endcase
     end
     //Declare submodules and connect i/o with wires
     //Memory submodule//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     Memory Memory(.MEM_CLK(CLK), .MEM_RDEN1(memRDEN1), .MEM_RDEN2(memRDEN2), .MEM_WE2(memWE2), .MEM_ADDR1(PCOUT15to2), .MEM_ADDR2(ALUOUT), 
                   .MEM_DIN2(RS2), .MEM_SIZE(DOUT13to12), .MEM_SIGN(DOUT114), .IO_IN(IOBUSIN), .IO_WR(IOBUSWR), .MEM_DOUT1(DOUT1), .MEM_DOUT2(DOUT2));
     //PC submodule//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////            
     PC PC(.JALR(BAGtoPCMUX_jalr), .BRANCH(BAGtoPCMUX_branch), .JAL(BAGtoPCMUX_jal), .PC_SOURCE(pcSource), .PC_WRITE(pcWrite), .PC_RST(reset), .CLK(CLK),
           .PC_ADDRESS(PCOUT), .ADDR_INC_OUT(PCINC));
     //Reg File submodule////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////     
     REG_FILE REG_FILE(.ADDR1(DOUT119to15), .ADDR2(DOUT124to20), .WA(DOUT111to7), .WD(regMUXOUT), .REG_WRITE(regWrite), .CLK(CLK), .RS1(RS1), .RS2(RS2));
     //Immediate Generator submodule/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     IMM_GEN IMM_GEN(.addr_in(DOUT31to7), .u_type(u_type), .i_type(i_type), .s_type(s_type), .b_type(b_type), .j_type(j_type));
     //BAG submodule/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     Branch_Address_Generator BAG(.j_type(j_type), .b_type(b_type), .i_type(i_type), .RS1(RS1), .PC(PCOUT), .jalr(BAGtoPCMUX_jalr), .branch(BAGtoPCMUX_branch),
                                  .jal(BAGtoPCMUX_jal));
     //ALU submodule/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     ALU ALU(.srcA(srcAMUXOUT), .srcB(srcBMUXOUT), .alu_func(alu_func), .result(ALUOUT));
     //BAG submodule/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     Branch_Cond_Generator BCG(.RS1(RS1), .RS2(RS2), .br_eq(br_eq), .br_lt(br_lt), .br_ltu(br_ltu));
     //Control Unit FSM submodule////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     CU_FSM CU_FSM(.ir6to0(DOUT16to0), .RESET(RST), .CLK(CLK), .PC_Write(pcWrite), .Reg_Write(regWrite), .Mem_WE2(memWE2), .Mem_RDEN1(memRDEN1),
                   .Mem_RDEN2(memRDEN2), .reset(reset));
     //Control Unit Decoder//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////             
     CU_DCDR CU_DCDR(.ir6to0(DOUT16to0), .ir14to12(DOUT114to12), .ir30(DOUT130), .br_eq(br_eq), .br_lt(br_lt), .br_ltu(br_ltu), .alu_fun(alu_func), 
     .alu_srcA(alu_srcAsel), .alu_srcB(alu_srcBsel), .PC_SOURCE(pcSource), .rf_wr_sel(regMUXsel));
endmodule
