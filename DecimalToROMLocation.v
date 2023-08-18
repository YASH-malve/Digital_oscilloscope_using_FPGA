`timescale 1ns / 1ps

module DecimalToROMLocation
    #(parameter DIGIT_BITS = 4,
                SELECT_CHARACTER_BITS = 7)
    (
    input clock,
    input [DIGIT_BITS-1:0] number2,
    input [DIGIT_BITS-1:0] number1,
    input [DIGIT_BITS-1:0] number0,
    output reg [SELECT_CHARACTER_BITS-1:0] character2 = 0,
    output reg [SELECT_CHARACTER_BITS-1:0] character1 = 0,
    output reg [SELECT_CHARACTER_BITS-1:0] character0 = 0
    );
    
    always @(posedge clock) begin
        character2 <= number2 + 16;
        character1 <= number1 + 16;
        character0 <= number0 + 16;
    end
    
endmodule
