module motor_control (
    input clk_16,
    input rst,
    input en,
    input [11:0] steps;
    input dir,

    output equal,
    output reg [3:0] stepper_pins
);
    reg [13:0] pos, next_pos;
    assign equal = (pos[13:3] >= steps);
    always @ (posedge clk_16 or posedge rst) begin
        if (rst) pos <= 14'd0;
        else pos <= next_pos;
    end
    always @ (*) begin
        if ((pos[13:3] >= steps) && en) next_pos = pos;
        else next_pos = pos + 1;
    end

    always @ (*)
        case (pos[2:0])
            0 : stepper_pins <= dir ? 4'b1000 : 4'b1001;
            1 : stepper_pins <= dir ? 4'b1100 : 4'b0001;
            2 : stepper_pins <= dir ? 4'b0100 : 4'b0011;
            3 : stepper_pins <= dir ? 4'b0110 : 4'b0010;
            4 : stepper_pins <= dir ? 4'b0010 : 4'b0110;
            5 : stepper_pins <= dir ? 4'b0011 : 4'b0100;
            6 : stepper_pins <= dir ? 4'b0001 : 4'b1100;
            7 : stepper_pins <= dir ? 4'b1001 : 4'b1000;
        endcase
endmodule;


module pouring_state_FSM (
    input clk,
    input rst
);
    
endmodule

module plate_motor_ctrl (
    input clk,
    input rst,
    input [2:0] pouring_state,

    output [3:0] plate_stepper_pins
);
    wire en = (pouring_state == `POUR || pouring_state == `ONE_SPOT);
    motor_control plat_motor (.clk_16(clk_16), .en(en), .rst(rst), .steps(12'd0), .dir(1'b0), .stepper_pins(plate_stepper_pins));
endmodule

module crane_motor_ctrl (
    input clk_23,
    input clk_16,
    input rst,
    input [2:0] pouring_state,

    output equal,
    output [3:0] crane_stepper_pins
);
    reg [11:0] steps;
    reg dir;
    motor_control cran_motor (.clk_16(clk_16), .en(0), .rst(rst || pouring_state == `IDLE));
    
    reg [11:0] counter, counter_next;
    always @ (posedge clk_23) begin
        if (pouring_state != `POUR)
            counter <= 12'd0;
        else
            counter <= counter_next;
    end
    always @ (*) begin
        counter_next = counter + 12'd1;
    end
endmodule

module water_pump_ctrl (
    input clk,
    input rst,
    input brewing_path,

    output water_pump
);
    
endmodule