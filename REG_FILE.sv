`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Spencer Seltzer
// 
// Create Date: 01/31/2023 09:26:35 AM
// Module Name: REG_FILE
// Target Devices:  Basys3
// Description: OTTER REG_FILE
//////////////////////////////////////////////////////////////////////////////////


module REG_FILE(
    input [4:0] ADDR1, //io for module
    input [4:0] ADDR2,
    input [4:0] WA,
    input [31:0] WD,
    input REG_WRITE,
    input CLK,
    output logic [31:0] RS1,
    output logic [31:0] RS2
    );
    
    logic [31:0] ram [0:31]; //create 32 register memory array
    
    //initialize all memory to zero
    initial begin
        int i;
        for(i=0; i<32; i=i+1) begin //loops through all memory and fills it with zeroes
            ram[i] = 0;
        end
    end
    //dual asyncronous reads of memory
    assign RS1 = ram[ADDR1]; //assigns content of reg located by addr1 to RS1 out
    assign RS2 = ram[ADDR2]; //assigns content of reg located by addr2 to RS2 out

    always_ff @(posedge CLK)
        begin
            if(REG_WRITE == 1'b1 && !WA == 5'b00000) //conditon so the zero register cannot be written to
                begin
                    ram[WA] <= WD; //stores what's on the wd input to the reg located by wa when REG_WRITE is high
                end
        end
endmodule
