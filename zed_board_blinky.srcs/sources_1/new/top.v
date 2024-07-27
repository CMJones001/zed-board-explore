`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 05/17/2024 05:49:59 PM
// Design Name:
// Module Name: blinky
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module blinky
(
    input GCLK,
    input reg [7:0] SW,
    output reg LD0,
    output reg LD1,
    output reg LD2,
    output reg LD3,
    output reg LD4,
    output reg LD5,
    output reg LD6,
    output reg LD7,
    output reg [7:0] JC
    );

    parameter int max_length = 26;

    reg [max_length:0] count = 0;
    reg [7:0] temp = 0;
    
    reg [3:0] data; 

    always @(posedge(GCLK)) begin
        data <= SW[3:0];
    end
    
    reg digit_select = 1;

    display_digit ssd_one(
        .clk(GCLK),
        .seven_seg_value(data),
        .digit_select(digit_select),
        .digit(JC)
    );

    always @(posedge(GCLK)) count <= count + 1;

    always @(*) begin
        case({ count[max_length], count[max_length-1], count[max_length-2] })
            3'b000 : temp = 8'b00000001;
            3'b001 : temp = 8'b00000010;
            3'b010 : temp = 8'b00000100;
            3'b011 : temp = 8'b00001000;
            3'b100 : temp = 8'b00010000;
            3'b101 : temp = 8'b00100000;
            3'b110 : temp = 8'b01000000;
            3'b111 : temp = 8'b10000000;

            default : temp = 8'b00000000;
        endcase
    end

    always @(posedge(GCLK)) begin
        {LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7} = temp;
    end
endmodule

module display_digit(
    input clk,
    input [3:0] seven_seg_value,
    input digit_select,
    output reg [7:0] digit
    );

    reg [7:0] temp;
    reg [7:0] select_array;

    assign digit = temp | select_array;

    always @(posedge clk) begin
        case (seven_seg_value)
          0:  temp <= 8'b1000_0000;
          1:  temp <= 8'b1000_1111;
          2:  temp <= 8'b0001_1000;
          3:  temp <= 8'b0000_1001;
          4:  temp <= 8'b0000_0111;
          5:  temp <= 8'b0010_0001;
          6:  temp <= 8'b0010_0000;
          7:  temp <= 8'b1000_1011;
          8:  temp <= 8'b0000_0000;
          9:  temp <= 8'b0000_0001;
         10:  temp <= 8'b0000_0010;
         11:  temp <= 8'b0010_0100;
         12:  temp <= 8'b1011_0000;
         13:  temp <= 8'b0000_1100;
         14:  temp <= 8'b0011_0000;
         15:  temp <= 8'b0011_0010;
         default: temp <= 8'b1011_1111;
        endcase
        case (digit_select)
          0:  select_array <= 8'b0100_0000;
          1:  select_array <= 8'b0000_0000;
        endcase
    end
endmodule

