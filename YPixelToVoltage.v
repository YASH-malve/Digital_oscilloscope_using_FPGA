`timescale 1ns / 1ps
module YPixelToVoltage
    #(parameter VOLTAGE_BITS = 12,
                DISPLAY_Y_BITS = 12,
                SCALE_EXPONENT_BITS = 4,
                Y_ZERO_VOLTS = 384,
                PIXELS_RELATIVE_TO_ZERO_VOLTS_TIMES_250_BITS = 18,
                PIXELS_RELATIVE_TO_ZERO_VOLTS_TIMES_250_BITS_TIMES_DEFAULT_SCALE = 21,
                DEFAULT_SCALE_VOLTAGE_RANGE = 10'sd256,
                DISPLAY_HEIGHT = 768,
                DISPLAY_HEIGHT_EXPONENT = 10,
                SCALE_TIMES_DISPLAY_HEIGHT_BITS = 20,
                SCALE_FACTOR_SIZE = 10)
    (
    input clock,
    input signed [DISPLAY_Y_BITS-1:0] y,
    input [SCALE_EXPONENT_BITS-1:0] scaleExponent,  //scale=8 -> scaleExponent=3
 //   input [SCALE_FACTOR_SIZE-1:0] scale,
    output reg signed [VOLTAGE_BITS-1:0] voltage,
    output reg [VOLTAGE_BITS-1:0] voltageAbsoluteValue,
    output reg isNegative  //0 if positive 1 if negative
    );
    
    reg signed [PIXELS_RELATIVE_TO_ZERO_VOLTS_TIMES_250_BITS-1:0] pixelsRelativeToZeroVoltsTimesVoltageRange;
    reg signed [PIXELS_RELATIVE_TO_ZERO_VOLTS_TIMES_250_BITS_TIMES_DEFAULT_SCALE-1:0] pixelsRelativeToZeroVoltsTimesVoltageRangeTimesDefaultScale;
    reg signed [PIXELS_RELATIVE_TO_ZERO_VOLTS_TIMES_250_BITS_TIMES_DEFAULT_SCALE-1:0] pixelsRelativeToZeroVoltsTimesVoltageRangeTimesDefaultScaleDividedByDisplayHeight;
    
    always @(posedge clock) begin
        //voltage = y*DEFAULT_VOLTAGE_RANGE*DEFAULT_SCALE/(DISPLAY_HEIGHT*scale)
        //voltage = y*250*8/(1,024*scale)
    
        //cycle 0
        pixelsRelativeToZeroVoltsTimesVoltageRange <= y * DEFAULT_SCALE_VOLTAGE_RANGE;
        
        //cycle 1
        pixelsRelativeToZeroVoltsTimesVoltageRangeTimesDefaultScale <= pixelsRelativeToZeroVoltsTimesVoltageRange <<< 3;  //multiply by 8 (DEFAULT_SCALE = 8)
        
        //cycle 2
        pixelsRelativeToZeroVoltsTimesVoltageRangeTimesDefaultScaleDividedByDisplayHeight <= 
                                        pixelsRelativeToZeroVoltsTimesVoltageRangeTimesDefaultScale >>> DISPLAY_HEIGHT_EXPONENT;
                                        
        //cycle 3
        voltage <= pixelsRelativeToZeroVoltsTimesVoltageRangeTimesDefaultScaleDividedByDisplayHeight >>> scaleExponent;
        
        //cycle 4
        isNegative <= (voltage < 0) ? 1'b1 : 1'b0;
        voltageAbsoluteValue <= (voltage > 0) ? voltage : ((~voltage) + 1);
    end
    
endmodule
