`timescale 1ns / 1ps


module SamplePeriodToTimePerDivision
    #(parameter SAMPLE_PERIOD_BITS = 6,
                SAMPLE_PERIOD_BITS_PLUS_ONE = 7,
                TIME_PER_DIVISION_BITS = 10)
    (input clock,
    input [SAMPLE_PERIOD_BITS-1:0] samplePeriod,
    output reg [TIME_PER_DIVISION_BITS-1:0] timePerDivision
    );
    
    reg [SAMPLE_PERIOD_BITS_PLUS_ONE-1:0] samplePeriodPlusOne;
    
    
    always @ (posedge clock) begin
        //cycle 0
        samplePeriodPlusOne <= samplePeriod + 1;
        
        //cycle 1
        timePerDivision <= samplePeriodPlusOne * 10;
    end
    
endmodule
