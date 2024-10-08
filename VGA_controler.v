always @(*) begin
    if (state == 2'b00) begin
        if (en)
            next_state = 2'b01;
        else
            next_state = 2'b00;
    end else if (state == 2'b01) begin
        if (en)
            next_state = 2'b10;
        else if (back)
            next_state = 2'b00;
        else
            next_state = 2'b01;
    end else if (state == 2'b10) begin
        if (en)
            next_state = 2'b11;
        else if (back)
            next_state = 2'b01;
        else
            next_state = 2'b10;
    end else begin
        if (finish)
            next_state = 2'b00;
        else
            next_state = 2'b11;
    end
end

module mode_FSM (
...
);
    // mode = 0, 1, 2
    reg [1:0] mode_out, nextmode;
    always @ (posedge clk_16 or posedge rst) begin
        if (rst) mode_out <= 2'b00;
        else mode_out <= next_mode;
    end
    always @(*) begin
            if (left && mode_out > 2'b00 && en) next_mode = mode_out - 1;
            else if (right && mode_out < 2'b10 && en) next_mode <= mode_out + 1;
            else next_mode = mode_out;
    end
    assign mode = mode_out;

endmodule;

module water_FSM(
...
);
    reg[3:0] ratio_out, next_ratio;
    always @(posedge clk_16 or posedge rst) begin
        if (rst) ratio_out <= 4'd15;
        else ratio_out <= next_ratio;
    end

    always @(*) begin
        if (left && ratio_out > 4'd12 && en) next_ratio = ratio_out - 1;
        else if (right && ratio_out < 4'd15 && en) next_ratio = ratio_out + 1;
        else next_ratio = ratio_out;
    end

    assign ratio = ratio_out;
    
endmodule;