`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Carl Jones
//
// Create Date: 05/17/2024 05:49:59 PM
// Design Name:
// Module Name: blinky
// Project Name:
// Target Devices: ZedBoard
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
    output [7:0] JC,
    output reg [7:0] JD
    );

    parameter int max_length = 26;

    reg [max_length:0] count = 0;

    reg [3:0] digit_one;
    reg [3:0] digit_two;
    reg [7:0] stored_switches;

    parameter ssd_switch_bit = 15;
    reg digit_select;

    parameter int duty_bits = 10; // 1024 counts
    parameter int duty_on = 2 ** duty_bits * 0.2; // ~ 20% duty

    // Set a disabling mask on the SSD that turns off the display
    // based on the duty cycle.
    reg [7:0] ssd_enable_mask;

    always @(posedge(GCLK)) begin
        // The display is high-off, so set all bits high, but don't mess with the
        // digit select bit.
        if (count[duty_bits-1:0] < duty_on) ssd_enable_mask = 8'h00;
        else ssd_enable_mask = 8'b1011_1111;
    end

    reg [7:0] ssd_c_out;
    assign JC = ssd_c_out | ssd_enable_mask;
    reg [7:0] ssd_d_out;
    assign JD = ssd_d_out | ssd_enable_mask;

    // Generete the 7-segment display output for each PMOD
    display_digit(
        .clk(GCLK),
        .seven_seg_value(digit_one),
        .digit_select(digit_select),
        .digit(ssd_c_out)
    );

    display_digit(
        .clk(GCLK),
        .seven_seg_value(digit_two),
        .digit_select(digit_select),
        .digit(ssd_d_out)
    );

    // Store data on pressing the middle button
    always @(posedge(GCLK)) begin
       if (BTNC) stored_switches <= SW;
       else stored_switches <= stored_switches;
    end

    // Swap between the digits
    always @(posedge(GCLK)) begin
        case (count[ssd_switch_bit])
            0 : begin
                digit_select <= 0;
                digit_one <=  SW[3:0];
                digit_two <= stored_switches[3:0];
            end
            1 : begin
                digit_select <= 1;
                digit_one <=  SW[7:4];
                digit_two <= stored_switches[7:4];
            end
        endcase
    end

    always @(posedge(GCLK)) count <= count + 1;

    LED_roller #(.count_length(max_length)) (
        .clk(GCLK),
        .count(count),
        .LED(LED)
    );

endmodule

module LED_roller
#(parameter count_length = 26)
(
    input reg clk,
    input reg [count_length:0] count,
    output reg [7:0] LED
);
    reg [7:0] led_out = 0;

    always @(posedge(clk)) begin
        case({ count[count_length], count[count_length-1], count[count_length-2] })
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

    always @(posedge(clk)) begin
        LED <= led_out;
    end
endmodule
