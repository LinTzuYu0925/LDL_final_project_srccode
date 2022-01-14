// This is the top module for coffee brewer
module coffee_brewer (
    input wire rst,
	input wire clk,
    inout wire PS2_DATA,
	inout wire PS2_CLK,

    // For motors
    output water_pump,
    output [3:0] plate_motor_step,
    output [3:0] crane_motor_step,

    // For VGA
    output hsync,
    output vsync,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue
);
    
endmodule