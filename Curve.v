`timescale 1ns / 1ps

`include "VerticalScaler.vh"

module Curve
    #(parameter DATA_IN_BITS = 12,
                SCALE_FACTOR_BITS = 10,
                DISPLAY_X_BITS = 12,
                DISPLAY_Y_BITS = 12,
                RGB_COLOR = 12'hFF0,  //yellow
                RGB_BITS = 12,
                DISPLAY_WIDTH = 1024,
                DISPLAY_HEIGHT = 768,
                REAL_DISPLAY_WIDTH = 1344,
                REAL_DISPLAY_HEIGHT = 806,
                HEIGHT_ZERO_PIXEL = DISPLAY_HEIGHT/2,
                ADDITIONAL_WAVE_PIXELS = 1,  //number of colored pixels below and on top of the actual wave
                ADDRESS_BITS = 12
                )
    (input clock,
    input signed [DATA_IN_BITS-1:0] dataIn,
    input [SCALE_FACTOR_BITS-1:0] verticalScaleFactorTimes8, // to allow for shrinking and growing the signal
    input [DISPLAY_X_BITS-1:0] displayX,
    input [DISPLAY_Y_BITS-1:0] displayY,
    input hsync,
    input vsync,
    input blank,
    input [RGB_BITS-1:0] previousPixel,
    output [RGB_BITS-1:0] pixel,
    output reg drawStarting,
    output reg [ADDRESS_BITS-1:0] address,
    output reg [DISPLAY_X_BITS-1:0] curveDisplayX,
    output reg [DISPLAY_Y_BITS-1:0] curveDisplayY,
    output reg curveHsync,
    output reg curveVsync,
    output reg curveBlank
    );    
    
    // todo get rid of bigMult; we shouldn't need it
    //scale dataIn
    wire signed [20:0] bigMult;
    wire signed [DATA_IN_BITS-1:0] scaledDataIn;
    //assign scaledDataIn = dataIn * verticalScaleFactorTimes8 / 'sd8; //`VERTICAL_SCALE(dataIn, verticalShiftLeftFactor);
    assign bigMult = dataIn * $signed(verticalScaleFactorTimes8);
    assign scaledDataIn = {bigMult[20], bigMult[13:3]};
    
    // figure out horiz location on screen
    // this has to be unsigned!
    wire [DATA_IN_BITS-1:0] dataScreenLocation;
    assign dataScreenLocation = HEIGHT_ZERO_PIXEL - scaledDataIn;
    
    reg pixelOn;
    
    always @(posedge clock) begin
        // TODO delay these by the correct number of cycles
        curveHsync <= hsync;
        curveVsync <= vsync;
        curveBlank <= blank;
        curveDisplayX <= displayX;
        curveDisplayY <= displayY;
        
        //control drawStarting
        if (displayX==(DISPLAY_WIDTH-1) && displayY==(DISPLAY_HEIGHT-1)) begin
            drawStarting <= 1;
        end else begin
            drawStarting <= 0;
        end
        
        //control pixel
        
        // data value above zero
        if ( (dataScreenLocation - ADDITIONAL_WAVE_PIXELS)<=displayY &&
             displayY<=(dataScreenLocation + ADDITIONAL_WAVE_PIXELS) ) begin
            pixelOn <= 1;
        end else begin
            pixelOn <= 0;
        end
        
        //control address
        if (0<=displayX && displayX<=(DISPLAY_WIDTH-5)) begin
            address <= displayX - (DISPLAY_WIDTH-5);
        end else if ((REAL_DISPLAY_WIDTH-4)<=displayX && displayX<=(REAL_DISPLAY_WIDTH-1) ) begin
            address <= displayX - (REAL_DISPLAY_WIDTH + DISPLAY_WIDTH - 5);
        end else begin
            //output address is irrelevant in this case
            address <= address;
        end
    end
    
    assign pixel = pixelOn ? RGB_COLOR : previousPixel;
    
endmodule