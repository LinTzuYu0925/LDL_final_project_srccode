module pouring_state_FSM (
    input clk,
    input rst
);
    
endmodule

module plate_motor_ctrl (
    input clk,
    input rst,
    input brewing_path,

    output [3:0] plate_motor_step
);
    
endmodule

module crane_motor_ctrl (
    input clk,
    input rst,
    input brewing_path,

    output [3:0] plate_motor_step
);
    
endmodule

module water_pump_ctrl (
    input clk,
    input rst,
    input brewing_path,

    output water_pump
);
    
endmodule