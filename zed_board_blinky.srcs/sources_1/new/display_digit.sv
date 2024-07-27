`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 06/07/2024 07:03:53 PM
// Design Name:
// Module Name: display_digit
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