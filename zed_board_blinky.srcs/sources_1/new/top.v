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
    input reg BTNC,
    output reg [7:0] LED,
    output reg [7:0] JC,
    output reg [7:0] JD
    );

    parameter int max_length = 26;

    reg [max_length:0] count = 0;
    reg [7:0] led_out = 0;
    
    reg [3:0] data;
    reg [7:0] stored_sw;
    reg [3:0] stored_data;

    parameter ssd_switch_bit = 15;
    reg digit_select;
    
    display_digit ssd_one_mod(
        .clk(GCLK),
        .seven_seg_value(data),
        .digit_select(digit_select),
        .digit(JC)
    );
    
    display_digit ssd_two_mod(
        .clk(GCLK),
        .seven_seg_value(stored_data),
        .digit_select(digit_select),
        .digit(JD)
    );
    
    always @(posedge(GCLK)) begin
       if (BTNC) stored_sw <= SW;
       else stored_sw <= stored_sw;
    end
    
    always @(posedge(GCLK)) begin 
        case (count[ssd_switch_bit])
            0 : begin
                digit_select <= 0;
                data <=  SW[3:0];
                stored_data <= stored_sw[3:0];
            end
            1 : begin
                digit_select <= 1;
                data <=  SW[7:4];
                stored_data <= stored_sw[7:4];
            end
        endcase
    end

    always @(posedge(GCLK)) count <= count + 1;
    always @(*) begin
        case({ count[max_length], count[max_length-1], count[max_length-2] })
            3'b000 : led_out = 8'b00000001;
            3'b001 : led_out = 8'b00000010;
            3'b010 : led_out = 8'b00000100;
            3'b011 : led_out = 8'b00001000;
            3'b100 : led_out = 8'b00010000;
            3'b101 : led_out = 8'b00100000;
            3'b110 : led_out = 8'b01000000;
            3'b111 : led_out = 8'b10000000;

            default : led_out = 8'b00000000;
        endcase
    end

    always @(posedge(GCLK)) begin
        // {LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7} = led_out;
        LED <= led_out;
    end
endmodule

module display_digit(
    input clk,
    input [3:0] seven_seg_value,
    input digit_select,
    output reg [7:0] digit
    );
  
    reg [7:0] digit_out_arr;
    reg [7:0] select_array;

    assign digit = digit_out_arr | select_array;

    always @(posedge clk) begin
          // We write the digit_out array in the form x0xx_xxxx
          // this controls the selected bits. 0 is on for a segment.
          // Segment layout:
          //  2
          // 3 5
          //  7
          // 0 4
          //  1
        case (seven_seg_value)
          0:  digit_out_arr <= 8'b1000_0000;
          1:  digit_out_arr <= 8'b1000_1111;
          2:  digit_out_arr <= 8'b0001_1000;
          3:  digit_out_arr <= 8'b0000_1001;
          4:  digit_out_arr <= 8'b0000_0111;
          5:  digit_out_arr <= 8'b0010_0001;
          6:  digit_out_arr <= 8'b0010_0000;
          7:  digit_out_arr <= 8'b1000_1011;
          8:  digit_out_arr <= 8'b0000_0000;
          9:  digit_out_arr <= 8'b0000_0001;
         10:  digit_out_arr <= 8'b0000_0010;
         11:  digit_out_arr <= 8'b0010_0100;
         12:  digit_out_arr <= 8'b1011_0000;
         13:  digit_out_arr <= 8'b0000_1100;
         14:  digit_out_arr <= 8'b0011_0000;
         15:  digit_out_arr <= 8'b0011_0010;
         default: digit_out_arr <= 8'b1011_1111;
        endcase
        
        // Bit-6 is used to choose the digit
        case (digit_select)
          0:  select_array <= 8'b0000_0000;
          1:  select_array <= 8'b0100_0000;
        endcase
    end
endmodule

